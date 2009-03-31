var RemoteUpload = {
  randomString: function(length) {
  	var chars = "0123456789abcdefghiklmnopqrstuvwxyz";
  	var randomString = '';
  	for (var i=0; i < length; i++) {
  		var rnum = Math.floor(Math.random() * chars.length);
  		randomString += chars.substring(rnum,rnum+1);
  	}
  	return randomString;
  }
}

RemoteUpload.Request = Class.create();
RemoteUpload.Request.prototype = {
  setOptions: function(options) {
    this.options = {
      idLength: (options.idLength || 10),
    }
    Object.extend(this.options, options || {});
  },

  //Create a unique ID for the iFrame
  //This ensures multiple remote_upload forms
  setUniqueId: function() {
    do {
      this.uniqueId = 'remote_uploader_'+RemoteUpload.randomString(this.options.idLength);
    } while($(this.uniqueId) != undefined);
  },

  initialize: function(form, options) {
    this.headers = new Array();
    this.form = $(form);

    this.setOptions(options);

    this.setUniqueId();    
    this.initializeForm();
    this.initializeHandler();
  },
  
  //Setup the form
  initializeForm: function() {
    //set the target to the new iFrame
    this.form.target = this.uniqueId;
    //ensure multipart/form-data encoding
    this.form.encoding = 'multipart/form-data';
    //ensure POST method
    this.form.method = 'post';

    //bind onsubmit to this handler
    this.form.onsubmit = this.formSubmit.bind(this);
    
    //add a "remote_upload" param to the action string
    this.form.action += (this.form.action.match(/\?/) ? '&' : '?') + 'remote_upload=1'
  },
  
  //Setup the iFrame
  initializeHandler: function() {
    //create a hidden iFrame with the name and ID set to our uniqueID
    this.iframe = document.createElement('iframe');
    this.iframe.style.display = 'none';
    this.iframe.name = this.iframe.id = this.uniqueId;

    //set the onload event to be handled by this instance
    this.iframe.onload = this.handleReturn.bind(this);
    
    //set it into the document
    this.form.appendChild(this.iframe);
  },

  formSubmit: function() {
    //Call 'Loading' readystate on form submission
    this.respondToReadyState(1)
  },

  //Pretty self explanitory
  respondToReadyState: function(readyState) {
    var event = Ajax.Request.Events[readyState];

    if (event == 'Complete') {
      (this.options['on' + this.status]
       || this.options['on' + (this.responseIsSuccess() ? 'Success' : 'Failure')]
       || Prototype.emptyFunction)(this.content);
       
      if ((this.header('Content-type') || '').match(/^text\/javascript/i))
       this.evalResponse();
    }

    (this.options['on' + event] || Prototype.emptyFunction)(this.content);

  },

  responseIsSuccess: function() {
    return this.status == undefined
        || this.status == 0 
        || (this.status >= 200 && this.status <= 300);
  },

  responseIsFailure: function() {
    return !this.responseIsSuccess();
  },
  
  header: function(name) {
    try {
      return this.headers[name];
    } catch (e) {}
  },
  
  handleReturn: function() {
    try {
      if(this.iframe.contentDocument.body.innerHTML != '') {
        this.respondToReadyState(2);
        
        content = this.iframe.contentDocument.body.innerHTML.split("<remote_upload:split>");

        this.status = this.headers['status'] = content[0];
        this.headers['Content-type'] = content[1];
        this.content = content[2];

        this.respondToReadyState(4);        
      }
    } catch(e) {}
  },

  evalResponse: function() {
    try {
      return eval(this.content);
    } catch (e) {
      this.dispatchException(e);
    }
  },

  dispatchException: function(exception) {
    (this.options.onException || Prototype.emptyFunction)(this, exception);
  }
};

RemoteUpload.Updater = Class.create();
Object.extend(Object.extend(RemoteUpload.Updater.prototype, RemoteUpload.Request.prototype), {
  initialize: function(container, form, options) {
    this.containers = {
      success: container.success ? $(container.success) : $(container),
      failure: container.failure ? $(container.failure) :
        (container.success ? null : $(container))
    }

    this.form = $(form);
    this.setOptions(options);

    this.setUniqueId();
    this.initializeForm();
    this.initializeHandler();
  },
  
  handleReturn: function(status, contentElement) {
    this.respondToReadyState(2);

    this.status = status;
    this.content = contentElement.innerHTML;
    var receiver = this.responseIsSuccess() ? this.containers.success : this.containers.failure;

    var match    = new RegExp(Ajax.Updater.ScriptFragment, 'img');
    var response = this.content.replace(match, '');
    var scripts  = this.content.match(match);

    if (receiver) {
      if (this.options.insertion) {
        new this.options.insertion(receiver, response);
      } else {
        receiver.innerHTML = response;
      }
    }

    if (this.responseIsSuccess()) {
      if (this.onComplete)
        setTimeout(this.onComplete.bind(this), 10);
    }

    if (this.options.evalScripts && scripts) {
      match = new RegExp(Ajax.Updater.ScriptFragment, 'im');
      setTimeout((function() {
        for (var i = 0; i < scripts.length; i++)
          eval(scripts[i].match(match)[1]);
      }).bind(this), 10);
    }
    
    this.respondToReadyState(4);
  }
});