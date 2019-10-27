module NooNoo
  module Components
    class Menu
      
      def self.props
        [
          {
            name: 'depth',
            type: 'radio',
            label: 'Depth',
            options: [
              {value: 1, label: 'Primary'},
              {value: 2, label: 'Secondary'},
              {value: 3, label: 'Tertiary'}
            ]
          }
        ]
      end

      def self.render(component, page, request)
        depth = component['depth'].to_i
        path_regexp = Regexp.new(page.path_parts[0..(depth-1)].join('/') + '.*')
        pages = Page.where(path: path_regexp).and(depth: depth).and(show_in_menus: true).only(:path, :label)
        {component: component, page: page, pages: pages}
      end

    end
  end
end