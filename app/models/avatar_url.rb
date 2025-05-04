class AvatarUrl
  attr_reader :avatarable, :size

  def initialize(avatarable, size: 64)
    @avatarable = avatarable
    @size = size
  end

  def image_url
    name = ERB::Util.url_encode(avatarable&.full_name || "Guest")
    background = "#0084FF"
    text = "#fff"
    "https://eu.ui-avatars.com/api/#{name}/#{size * 2}/#{background.delete_prefix("#")}/#{text.delete_prefix("#")}"
  end
end
 self.table_name = 'column_metadatas'