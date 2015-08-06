module NooNoo
  module Components
    class Menu

      def self.render(component, page, request)
        depth = component['depth'].to_i
        path_regexp = Regexp.new(page.path_parts[0..(depth-1)].join('/') + '.*')
        pages = Page.where(path: path_regexp).and(depth: depth).and(show_in_menus: true).only(:path, :label)
        {page: page, component: component, pages: pages}
      end

    end
  end
end