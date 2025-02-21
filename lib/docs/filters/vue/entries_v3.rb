module Docs
  class Vue
    class EntriesV3Filter < Docs::EntriesFilter
      def get_name
        if slug == 'api/' || slug == 'api/index'
          'API'
        elsif slug == 'style-guide/'
          'Style Guide'
        else
          name = at_css('h1').content
          name = _fix_name(name)
          subtype = at_css('.sidebar-heading.open, .sidebar-heading.active, .sidebar-link.active')
          index = css('.sidebar-link').to_a.index(at_css('.sidebar-link.active'))
          name.prepend "#{index + 1}. " if index && !slug.start_with?('api')
          name.concat " (#{subtype.content.strip})" if subtype && slug.start_with?('guide')
          name
        end
      end

      def _fix_name(name)
        name.sub! %r{#\s*}, ''
        name.sub! %r{\s*3\.\d\+$}, ''
        name
      end

      def get_type
        if slug.start_with?('guide/migration')
          'Migration'
       elsif slug.start_with?('guide')
          'Guide'
        elsif slug == 'style-guide/'
          'Style Guide'
        else
          title = at_css('.sidebar-heading.open, .sidebar-heading.active, .sidebar-link.active').content.strip
          title = _fix_name(title)
          "API: #{title}"
        end
      end

      def additional_entries
        return [] if slug.start_with?('guide')
        type = nil

        css('h2, h3').each_with_object [] do |node, entries|
          if node.name == 'h2'
            type = node.content.strip
            type = _fix_name(type)
            next if slug == 'style-guide/'
            name = "#{get_type}: #{type}"
            name.sub! %r{^API: }, ''
            entries << [name, node['id'], get_type]
          elsif slug == 'style-guide/'
            next if node['id'].match(/rule-categories|priority-/)
            name = node.content.strip
            name = _fix_name(name)
            name.sub! %r{\(.*\)}, '()'
            name.sub! /(essential|strongly recommended|recommended|use with caution)\Z/, ''
            entries << [name, node['id'], 'Style Guide']
          end
        end
      end
    end
  end
end
