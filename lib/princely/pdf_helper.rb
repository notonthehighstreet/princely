module PdfHelper
  require 'princely'

  def render(options = nil, *args, &block)
    if options.is_a?(Hash) && options.has_key?(:pdf)
      options[:name] ||= options.delete(:pdf)
      make_and_send_pdf(options.delete(:name), options)
    else
      super
    end
  end

  private

  def make_pdf(options = {})
    options[:stylesheets] ||= []
    options[:layout] ||= false
    options[:template] ||= File.join(controller_path,action_name)

    prince = Princely.new
    # Sets style sheets on PDF renderer
    prince.add_style_sheets(*options[:stylesheets].collect{|style| asset_file_path(style)})
    html_string = html_string(options)

    # Send the generated PDF file from our html string.
    if filename = options[:filename] || options[:file]
      prince.pdf_from_string_to_file(html_string, filename)
    else
      prince.pdf_from_string(html_string)
    end
  end

  def html_string(options)
    html_string = render_to_string(:template => options[:template], :layout => options[:layout])

    # Make all paths relative, on disk paths...
    html_string.gsub!(".com:/",".com/") # strip out bad attachment_fu URLs
    html_string.gsub!( /src=["']+([^:]+?)["']/i, "src=\"#{Rails.public_path}/\\1\"")

    # Remove asset ids on images with a regex
    html_string.gsub!( /src=["'](\S+\?\d*)["']/i ) { |m| 'src="' + $1.split('?').first + '"' }
    html_string
  end

  def make_and_send_pdf(pdf_name, options = {})
    options[:disposition] ||= 'attachment'
    send_data(
      make_pdf(options),
      :filename => pdf_name + ".pdf",
      :type => 'application/pdf',
      :disposition => options[:disposition]
    )
  end

  def asset_file_path(asset)
    if Rails.application.assets
      # Remove /assets/ from generated names and try and find a matching asset
      Rails.application.assets.find_asset(asset.gsub(/\/assets\//, "")).try(:pathname) || asset
    else
      stylesheet = asset.to_s.gsub(".css","")
      File.join(config.stylesheets_dir, "#{stylesheet}.css")
    end
  end
end
