namespace :elasticsearch do
  namespace :index do
    desc "Create a new index. Specify IMPORT=1 for rebuilding from resource"
    task create: :environment do
      ENV['INDEX'] = new_index_name = "#{Spot.index_name}_#{Time.now.strftime("%Y%m%d_%H%M%S")}"

      puts "========== create #{new_index_name} =========="
      Spot.create_index!(name: new_index_name)

      if ENV['IMPORT'].to_i.nonzero?
        puts "========== import #{new_index_name} from data sources =========="

        batch_size = ENV['BATCH_SIZE'] || 1000
        Spot.__elasticsearch__.import(index: new_index_name, type: Spot.document_type, batch_size: batch_size)
      end

      if ENV['COMMIT'].to_i.nonzero?
        Rake::Task["elasticsearch:alias:switch"].invoke
      end

      puts "[INDEX][Spot] Created: #{new_index_name}"
    end
  end

  namespace :alias do
    task switch: :environment do
      raise "INDEX should be given" unless ENV['INDEX']
      new_index_name = ENV['INDEX']

      puts "========== put an alias named #{Spot.index_name} to #{new_index_name} =========="
      Spot.switch_alias!(alias_name: Spot.index_name, new_index: new_index_name)
    end
  end
end
