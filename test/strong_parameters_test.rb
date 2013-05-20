require 'strong_parameters'
require File.expand_path('test_helper', File.dirname(__FILE__))

class Widget
  extend ActiveModel::Naming
end

class Hotel
  extend ActiveModel::Naming
end

class WidgetsController < InheritedResources::Base
end

class HotelsController < InheritedResources::Base
  def hotel_params
    params.require(:hotel).permit(:permitted)
  end
  private :hotel_params
end

class StrongParametersTest < ActionController::TestCase
  def setup
    @controller = WidgetsController.new
    @controller.stubs(:widget_url).returns("/")
    @controller.stubs(:permitted_params).returns(:widget => {:permitted => 'param'})
    class << @controller
      private :permitted_params
    end
  end

  def test_permitted_params_from_new
    Widget.expects(:new).with(:permitted => 'param')
    get :new, :widget => { :permitted => 'param', :prohibited => 'param' }
  end

  def test_permitted_params_from_create
    Widget.expects(:new).with(:permitted => 'param').returns(mock(:save => true))
    post :create, :widget => { :permitted => 'param', :prohibited => 'param' }
  end

  def test_permitted_params_from_update
    mock_widget = mock
    mock_widget.stubs(:class).returns(Widget)
    mock_widget.expects(:update_attributes).with(:permitted => 'param')
    Widget.expects(:find).with('42').returns(mock_widget)
    put :update, :id => '42', :widget => {:permitted => 'param', :prohibited => 'param'}
  end

  # permitted_params has greater priority
  def test_with_permitted_and_resource_methods
      @controller.stubs(:widget_params).returns(:permitted => 'another_param')
      class << @controller
        private :widget_params
      end
      Widget.expects(:new).with(:permitted => 'param')
      get :new, :widget => { :permitted => 'param', :prohibited => 'param' }
  end
end

class StrongParametersWithoutPermittedParamsMethodTest < ActionController::TestCase
  def setup
    @controller = WidgetsController.new
    @controller.stubs(:widget_url).returns("/")
    @controller.stubs(:widget_params).returns(:permitted => 'param')
    class << @controller
      private :widget_params
    end
  end

  def test_specific_resource_params_method_overriden
    Widget.expects(:new).with(:permitted => 'param').returns(mock(:save => true))
    post :create, :widget => { :permitted => 'param', :prohibited => 'param' }
  end
end

class StrongParametersWithRequireTest < ActionController::TestCase
  def setup
    @controller = HotelsController.new
    @controller.stubs(:hotel_url).returns("/")
  end

  def test_permitted_params_from_new
    Hotel.expects(:new).with('permitted' => 'param')
    get :new, :hotel => { :permitted => 'param', :prohibited => 'param' }
  end

  def test_permitted_params_from_create
    Hotel.expects(:new).with( 'permitted' => 'param').returns(mock(:save => true))
    post :create, :hotel => { :permitted => 'param', :prohibited => 'param' }
  end

  def test_permitted_params_from_update
    mock_hotel = mock
    mock_hotel.stubs(:class).returns(Hotel)
    mock_hotel.expects(:update_attributes).with('permitted' => 'param')
    Hotel.expects(:find).with('42').returns(mock_hotel)
    put :update, :id => '42', :hotel => {:permitted => 'param', :prohibited => 'param'}
  end
end
