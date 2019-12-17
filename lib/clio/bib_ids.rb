# Clio::BibIds encapsulates Bib ID functionality (as a set) as it relates to CLIO

module Clio
  class BibIds
    class << self
      # argument: Bib ID
      # returns: true or false
      def generate_stub?(bib_id)
        check_data_files(bib_id)
      end

      # method will check the data files to see if a stub should be generated
      # for this bib id.
      def check_data_files(bib_id)
        search_string = '<field name="id">ldpd_' + "#{bib_id}" + '</field>'
        result = false
        result = Dir.glob(File.join(CONFIG[:clio_bib_id_data_dir],'*.xml')).any? do |file|
          data_file_contains_string?(file, search_string)
        end
        result
      end

      def data_file_contains_string?(absolute_filepath_filename, search_string)
        File.open(absolute_filepath_filename) do |f|
          f.any? do |line|
            line.include?(search_string)
          end
        end
      end
    end
  end
end
