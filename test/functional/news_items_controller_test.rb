require File.dirname(__FILE__) + '/../test_helper'
require 'news_items_controller'

# Re-raise errors caught by the controller.
class NewsItemsController; def rescue_action(e) raise e end; end

class NewsItemsControllerTest < Test::Unit::TestCase
  fixtures :news_items

  def setup
    @controller = NewsItemsController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    login_as :quentin # login as an admin so we can perform the tasks.
  end

  def test_should_get_index
    get :index
    assert_response :success
    assert assigns(:news_items)
  end

  def test_should_get_new
    get :new
    assert_response :success
  end
  
  def test_should_create_news_item
    old_count = NewsItem.count
    post :create, :news_item => {:name => 'New Article', :body => 'This is a new article.' }
    assert_equal old_count+1, NewsItem.count
    
    assert_redirected_to news_item_path(assigns(:news_item))
  end

  def test_should_show_news_item
    get :show, :id => 1
    assert_response :success
  end

  def test_should_get_edit
    get :edit, :id => 1
    assert_response :success
  end
  
  def test_should_update_news_item
    put :update, :id => 1, :news_item => { }
    assert_redirected_to news_item_path(assigns(:news_item))
  end
  
  def test_should_destroy_news_item
    old_count = NewsItem.count
    delete :destroy, :id => 1
    assert_equal old_count-1, NewsItem.count
    
    assert_redirected_to news_items_path
  end
end
