require 'nokogiri'
require 'open-uri'
require 'csv'

class Post
  attr_reader :id

  def initialize(attributes={}) #less fragile than *
    @title    = attributes[:title]
    @url      = attributes[:url]
    @pts      = attributes[:pts]
    @id       = attributes[:id]
    @comments = attributes[:comments]
  end

  def add_comment(text)
    @text = text
  end
end

class Comment
  attr_reader :text

  def initialize(text)
    @text = text
  end
end

class FileParser
  def initialize(path)
    @doc = Nokogiri::HTML(File.open(path))
    extract_title
    extract_url
    extract_points
    extract_item_id
    extract_number_of_comments
    extract_comments
    @posts = []
    @all_comments = []
  end

  def extract_title
    @title = @doc.search('td.title > a').text
  end

  def extract_url
    @url = @doc.search('td.title span').text.strip[1..-2]
  end

  def extract_points
    @pts = @doc.search('.subtext span').text
  end

  def extract_item_id
    @id = @doc.search('.subtext > a:nth-child(3)').map {|link| link['href'] }.join
  end

  def extract_number_of_comments
    @comments = @doc.search('.subtext > a:nth-child(3)').text
  end

  def spawn_post
    @posts << Post.new(:title => @title, :url => @url, :pts => @pts, :id => @id, :comments => @comments)
  end

  def extract_comments
    @doc.search('.comment').map{ |comment| comment.text }
  end

  def spawn_comments
    extract_comments.each do |comment|
      @all_comments << Comment.new(comment)
    end
  end

  def comments_to_csv
    CSV.open("#{@posts[0].id}","w") do |file|
      @all_comments.each do |comment|
        file << [comment.text]
      end
    end
  end
end

parser = FileParser.new(ARGV[0])
parser.spawn_post
parser.spawn_comments
parser.comments_to_csv
