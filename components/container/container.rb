module NooNoo
  module Components
    class Container

      def self.render(component, page, request)
        
        {page: page, component: component}
      end

    end
  end
end