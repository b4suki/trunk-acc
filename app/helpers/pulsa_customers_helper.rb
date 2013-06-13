module PulsaCustomersHelper
  def pulsa_seting_choise
    options = PulsaSetting.find(:all).collect {|p| ["#{p.item.name} | #{p.item.item_code}", p.item_id] }
    return options.unshift(["- Pilih -",""])
  end
end
