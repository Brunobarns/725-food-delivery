require 'csv'

class BaseRepository
  def initialize(csv_file_path)
    @csv_file_path = csv_file_path
    @elements = []
    @next_id = 1
    load_csv if File.exist?(csv_file_path)
  end

  def all
    @elements
  end

  def create(element)
    element.id = @next_id
    @next_id += 1
    @elements << element
    save_csv
  end

  def find(id)
    @elements.find { |element| element.id == id }
  end

  private

  # Must be implemented (overridden) by child class
  def build_element(row)
    raise StandardError, 'Not implemented!'
  end

  # Must be implemented (overridden) by child class
  def csv_headers
    raise StandardError, 'Not implemented!'
  end

  # Must be implemented (overridden) by child class
  def build_csv_row(element)
    raise StandardError, 'Not implemented!'
  end

  def load_csv
    csv_options = {
      headers: :first_row,
      header_converters: :symbol
    }
    CSV.foreach(@csv_file_path, csv_options) do |row|
      element = build_element(row)
      @elements << element
    end
    @next_id = @elements.last.id + 1 unless @elements.empty?
  end

  def save_csv
    CSV.open(@csv_file_path, 'wb') do |csv|
      csv << csv_headers
      @elements.each do |element|
        csv << build_csv_row(element)
      end
    end
  end
end
