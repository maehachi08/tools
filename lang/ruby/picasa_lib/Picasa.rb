#!/root/.rbenv/versions/1.9.3-p194/bin/ruby
class Picasa
  require 'net/http'
  require 'rexml/document'

  # コンストラクタ
  def initialize(user_id,url="picasaweb.google.com",port=80)
    @user_id = user_id
    @url     = url
    @port    = port
    @base_path = "/data/feed/api/user/#{@user_id}"
  end

  # XML取得
  def get_xml(path=nil)
    xml = ""
    @add_path = path
    Net::HTTP.version_1_2
    Net::HTTP.start("#{@url}", "#{@port}") {|http|
      response = http.get("#{@base_path}/#{@add_path}")
      xml = response.body
    }
    return xml
  end


  # アルバムIDとアルバム名をハッシュ形式で返す
  def albums
    album_id        = ""
    album_name      = ""
    albums = {}

    xml = self.get_xml()
    doc = REXML::Document.new(xml)

    doc.elements.each('/feed/entry/gphoto:id') do |album_id_element|
      album_id = album_id_element.text
      path = "albumid/#{album_id}"
      album_xml = self.get_xml(path)
      album_doc = REXML::Document.new(album_xml)

      album_doc.elements.each('/feed/title') do |album_title_element|
        album_name =  album_title_element.text
      end

      albums[album_id] = album_name
    end

    return albums
  end


  def get_photo_xml( url )
    xml = ""
    @url = "picasaweb.google.com"
    @port = "80"
    add_path = url.sub(/http:\/\/picasaweb\.google\.com:80/,'')
    Net::HTTP.version_1_2
    Net::HTTP.start("#{@url}", "#{@port}") {|http|
      response = http.get("#{add_path}")
      xml = response.body
    }
    return xml
  end


  # サムネイル画像のURLを返す
  def get_album_thumbnail(album_id)
    album_thumbnail = ''
    xml = self.get_xml()
    doc = REXML::Document.new(xml)
    path = "albumid/#{album_id}"
    album_xml = self.get_xml(path)
    album_doc = REXML::Document.new(album_xml)

    album_doc.elements.each('/feed/icon') do |album_thumbnail_element|
      album_thumbnail =  album_thumbnail_element.text
    end

    return album_thumbnail
  end

  # 特定アルバムの写真URLを返す
  def get_photos(album_id)
    album_id       = album_id
    album_photos   = {}
    photos         = {}
    photo_urls     = []
    photo_titles   = []
    photo_urls     = []

    album_path     = "albumid/#{album_id}"
    album_response = get_xml( album_path )

    # albumごとのXMLを読み込む
    # http://picasaweb.google.com/data/feed/api/user/102882299756826510757/albumid/5868229047254103345
    album_document = REXML::Document.new( album_response )

    album_document.elements.each('/feed/entry/gphoto:id') do |photo_id_element|
      photo_id       = photo_id_element.text

      photo_path     = "photoid/#{photo_id}"
      path           = "#{album_path}/#{photo_path}"
      photo_response = get_xml( path )
      photo_document = REXML::Document.new( photo_response )
      
      #raise doc.elements["/entry/media:group/media:description"].attributes['url'].text
      photo_id          = photo_document.elements["/feed/id"].text
      photo_url         = photo_document.elements["/feed/media:group/media:content"].attributes['url']
      photo_description = photo_document.elements["/feed/media:group/media:description"].text
      photo_title       =  photo_document.elements["/feed/media:group/media:title"].text

      photo_array = {
        "photo_url"         => photo_url,
	"photo_description" => photo_description,
	"photo_title"       => photo_title,
      }

      photos["#{photo_id}"] = photo_array
    end
    return photos
  end

  # 全アルバムの写真URLを返す
  def get_all_photos
    array_of_hash = []
    all_albums    = self.albums

    all_albums.keys do |album_id|
      array_of_hash << self.get_photos( album_id )
    end

    return array_of_hash
  end

  # アルバムタイトル名取得
  def album_title( album_id )
    album_title = ''
    path        = "albumid/#{album_id}"
    album_xml   = self.get_xml(path)
    album_doc   = REXML::Document.new(album_xml)

    album_doc.elements.each('/feed/title') do |album_title_element|
      album_title =  album_title_element.text
    end

    return album_title
  end


  # ユーザの総アルバム数取得
  def counts
    album_names     = []
    xml             = self.get_xml()
    doc             = REXML::Document.new(xml)

    doc.elements.each('/feed/entry/gphoto:id') do |album_id_element|
      album_id  = album_id_element.text
      path      = "albumid/#{album_id}"
      album_xml = self.get_xml(path)
      album_doc = REXML::Document.new(album_xml)

      album_doc.elements.each('/feed/title') do |album_title_element|
        album_name =  album_title_element.text
        album_names.push album_name
      end

    end

    return album_names.size
  end






end

# debug
# http://picasaweb.google.com/data/feed/api/user/102882299756826510757
picasa_obj = Picasa.new("102882299756826510757")
album_title = picasa_obj.get_photos("5868229047254103345")
