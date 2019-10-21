module ConcertoFrontendVue
  class Engine < ::Rails::Engine
    isolate_namespace ConcertoFrontendVue
    engine_name "concerto_frontend_vue"

    initializer "set field configs" do |app|
      app.config.field_configs[:entry_transition][:values] = 
        [
          # "Attention Seekers"
          "bounce", "flash", "pulse", "rubberBand", "shake", "swing", "tada", "wobble", "jello", "heartBeat", 
          # "Bouncing Entrances"
          "bounceIn", "bounceInDown", "bounceInLeft", "bounceInRight", "bounceInUp", 
          # "Fading Entrances"
          "fadeIn", "fadeInDown", "fadeInDownBig", "fadeInLeft", "fadeInLeftBig", "fadeInRight", "fadeInRightBig", "fadeInUp", "fadeInUpBig", 
          # "Flippers"
          "flip", "flipInX", "flipInY", 
          # "Lightspeed"
          "lightSpeedIn",
          # "Rotating Entrances"
          "rotateIn", "rotateInDownLeft", "rotateInDownRight", "rotateInUpLeft", "rotateInUpRight", 
          # "Sliding Entrances"
          "slideInUp", "slideInDown", "slideInLeft", "slideInRight", 
          # "Zoom Entrances"
          "zoomIn", "zoomInDown", "zoomInLeft", "zoomInRight", "zoomInUp", 
          # "Specials"
          "jackInTheBox", "rollIn"
        ] + app.config.field_configs[:entry_transition][:values]

      app.config.field_configs[:exit_transition][:values] = 
        [
          # "Bouncing Exits"
          "bounceOut", "bounceOutDown", "bounceOutLeft", "bounceOutRight", "bounceOutUp", 
          # "Fading Exits"
          "fadeOut", "fadeOutDown", "fadeOutDownBig", "fadeOutLeft", "fadeOutLeftBig", "fadeOutRight", "fadeOutRightBig", "fadeOutUp", "fadeOutUpBig", 
          # "Flippers"
          "flip", "flipOutX", "flipOutY", 
          # "Lightspeed"
          "lightSpeedOut", 
          # "Rotating Exits"
          "rotateOut", "rotateOutDownLeft", "rotateOutDownRight", "rotateOutUpLeft", "rotateOutUpRight", 
          # "Sliding Exits"
          "slideOutUp", "slideOutDown", "slideOutLeft", "slideOutRight",   
          # "Zoom Exits"
          "zoomOut", "zoomOutDown", "zoomOutLeft", "zoomOutRight", "zoomOutUp", 
          # "Specials"
          "hinge", "rollOut"
        ] + app.config.field_configs[:exit_transition][:values]
    end

    # Define plugin information for the Concerto application to read
    def plugin_info(plugin_info_class)
      @plugin_info ||= plugin_info_class.new do
        add_view_hook "frontend/ScreensController", :concerto_frontend, partial: "concerto_frontend_vue/frontend"
      end
    end

  end
end
