module VendorsHelper
  def validate_unique_vendors(option)
    acc = []        
    Vendor.find(:all).each do |p|        
      case option
      when "name"
        then
        acc << "#{p.name}"
      when "phone"
        then
        acc << "#{p.phone}"
      when "fax"
        then
        acc << "#{p.fax}"
      end
    end    
    return acc
  end
end
