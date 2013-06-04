require 'jquery-rails'
require 'jquery-rails-cdn/version'

module Jquery::Rails::Cdn
  module ActionViewExtensions
    JQUERY_VERSION = Jquery::Rails::JQUERY_VERSION
    JQUERY_UI_VERSION = Jquery::Rails::JQUERY_UI_VERSION
    OFFLINE = (Rails.env.development? or Rails.env.test?)

    URL = {
      :core => {
        :google             => "//ajax.googleapis.com/ajax/libs/jquery/#{JQUERY_VERSION}/jquery.min.js",
        :microsoft          => "//ajax.aspnetcdn.com/ajax/jQuery/jquery-#{JQUERY_VERSION}.min.js",
        :jquery             => "http://code.jquery.com/jquery-#{JQUERY_VERSION}.min.js",
        :yandex             => "//yandex.st/jquery/#{JQUERY_VERSION}/jquery.min.js",
        :cloudflare         => "//cdnjs.cloudflare.com/ajax/libs/jquery/#{JQUERY_VERSION}/jquery.min.js"
      },
      :ui => {
        :google             => "//ajax.googleapis.com/ajax/libs/jqueryui/#{JQUERY_UI_VERSION}/jquery-ui.min.js",
        :microsoft          => "//ajax.aspnetcdn.com/ajax/jquery.ui/#{JQUERY_UI_VERSION}/jquery-ui.min.js",
        :jquery             => "https://code.jquery.com/ui/#{JQUERY_UI_VERSION}/jquery-ui.min.js",
        :yandex             => "//yandex.st/jquery-ui/#{JQUERY_UI_VERSION}/jquery-ui.min.js",
        :cloudflare         => "//cdnjs.cloudflare.com/ajax/libs/jqueryui/#{JQUERY_UI_VERSION}/jquery-ui.min.js"
      }
    }

    def jquery_url(name)
      URL[:core][name]
    end

    def jquery_ui_url(name)
      URL[:ui][name]
    end

    def jquery_include_tag(name, options = {})
      include_jquery_ui = options.delete :include_jquery_ui

      return javascript_include_tag(:jquery, options) if OFFLINE and !options.delete(:force)
      
      output = [ javascript_include_tag(jquery_url(name), options) ]
      output << javascript_include_tag(jquery_ui_url(name), options) if include_jquery_ui
      output << local_jquery_tag(options)
      output << local_jquery_ui_tag(options) if include_jquery_ui
        
      output.join("\n").html_safe
    end

    def jquery_ui_include_tag(name, options = {})
      return javascript_include_tag('jquery-ui', options) if OFFLINE and !options.delete(:force)

      [ javascript_include_tag(jquery_ui_url(name), options),
        local_jquery_ui_tag(options)
      ].join("\n").html_safe
    end

    private
      def local_jquery_tag(options)
        javascript_tag("window.jQuery || document.write(unescape('#{javascript_include_tag(:jquery, options).gsub('<','%3C')}'))")
      end

      def local_jquery_ui_tag(options)
        javascript_tag("(window.jQuery && window.jQuery.ui) || document.write(unescape('#{javascript_include_tag('jquery-ui', options).gsub('<','%3C')}'))")
      end
  end

  class Railtie < Rails::Railtie
    initializer 'jquery_rails_cdn.action_view' do |app|
      ActiveSupport.on_load(:action_view) do
        include Jquery::Rails::Cdn::ActionViewExtensions
      end
    end
  end
end
