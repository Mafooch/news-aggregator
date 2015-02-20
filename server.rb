require 'pry'
require 'sinatra'
require 'csv'

ARTICLE_FILE = 'articles.csv'

def add_article(params)
  article = [params[:title], params[:url], params[:description]]
  CSV.open(ARTICLE_FILE, 'a') do |file|
    file << article
  end
end

def get_articles
  articles = []
  CSV.foreach(ARTICLE_FILE, headers: true, header_converters: :symbol) do |row|
    articles << row.to_hash
  end
  articles
end

def valid_article?(params)
  !params[:title].empty? && !params[:url].empty? && !params[:description].empty?
end

def get_error_messages(params)
  messages = []

  messages << "Title is blank." if params[:title].empty?
  messages << "URL is blank." if params[:url].empty?
  messages << "Description is blank." if params[:description].empty?
  messages
end

def article_to_params(params)
  param_string = "?"
  params.each do |key, value|
    param_string << "#{key}=#{value}&"
  end
  param_string
end

##########
# ROUTES #
##########

get '/' do
  redirect '/articles'
end

get '/articles' do
  erb :'articles/index', locals: { articles: get_articles }
end

get '/articles/new' do
  if !params.empty?
    error_messages = get_error_messages(params)
  else
    error_messages = ''
  end

  erb :'articles/new', locals: { errors: error_messages }
end

post '/articles/new' do
  if valid_article?(params)
    add_article(params)
    redirect '/articles'
  else
    redirect "/articles/new#{article_to_params(params)}"
    # pass the error messages to the get /articles/new
    # populate form with correct fields
  end
end


