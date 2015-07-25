module NooNoo
  module Components
    class Menu

      def self.render(component, page, request)
        pages = nil
        if component['show'] == 'children'
          pages = getChildPages(page)
        else
          pages = getTopLevelPages
        end
        {page: page, component: component, pages: pages}
      end
  
    private

      def self.getTopLevelPages
        Page.where(depth: 1).and(show_in_menus: true).only(:path, :label)
      end
      
      def self.getChildPages(page)
        regexp = Regexp.new("#{page.path}/.*")
        Page.where(path: regexp).and(show_in_menus: true).only(:path, :label)
      end
      
    end
  end
end