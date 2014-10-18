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
        Page.where(depth: 1).only(:path, :title)
      end
      
      def self.getChildPages(page)
        regexp = Regexp.new("#{page.path}/.*")
        Page.where(path: regexp).only(:path, :title)
      end
      
    end
  end
end