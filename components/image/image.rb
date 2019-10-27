module NooNoo
  module Components
    class Image
      
      def self.props
        [
          {name: 'width', type: 'string', label: 'Width'},
          {name: 'height', type: 'string', label: 'Height'},
          {name: 'src', type: 'string', label: 'Source URL'}
        ]
      end

    end
  end
end