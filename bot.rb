require 'rest-client'
require 'telegram/bot'
require 'yaml'

FORMAT_MESSAGE = 'Enter message in next format to log expense: {amount};{currency_3_chars};{category};{place}, example: 15;USD;Food;McDonalds.'.freeze
GREETINGS = ["Sveiki","Habari za asubuhi","Bula","Dumela","Selamat Pagi","Zou san","Mwashibukeni","Shlam'alokhon","Namaste","Përshëndetje","Dzien dobry","Ahoj","suprabhat","Dumela","Anyeong Haseyo","MarÃ­-marÃ­","Neih hou","Annyunghaseyo","Dobro utro","Salaam Aleekum","Zdravo","Kaixo","Bongu","Sat Shri Akal","Tere hommikust","God morgen","Bunâ","Hyvää huomenta","Shuvo sokal","Akkam","Dila mushwidobisa","Inaa kwana","Buenos dias","Sabaidee","Subhodayamu","Khurumjari","Bonjou","Ciao","Hallå","Dzień dobry","Shalom","Shubhodaya","Maayong aga","Myttin da","Hola","bon matin","buenos días","Xin Chào","Bhota","Muga rukiiri","Halló","Choum Reap Sor","Olá","Allianchu","Hyālō","Li-hó","Salam","Zdravo","Livukenjani","Buon giorno","Jo reggelt","Labas reytas","Kia Ora","Khairli kun","Molweni","Dobro jutro","Günaydin","Barev Dzez","Kumusta","mālō tau ma‘u e pongipongi ni","Salom","U zuhile","Subbakhair","Bonan matenon","Egun on","Selamat pagi","Buna dimineata","Sveika (male) Sveiks (female)","S’mae","Kali mera","Dia Duit","Demat","E karo","Me ma wo akye","Bom dia","Dobry Dzień","Gudde moien","Halo","Henda ho","Dobro jutro","Arrun Suo Sdey","Aloha","Privet","Goeie môre","Gamarjoba","On zoh","Muraho","Thobela","Szia","Hei","Suprabhataha","Nyado delek","Ahoj","Yá'át'ééh abíní","Iorana","Bon dia","Bos dias","Sain uu","Dobryj Den","Suba Udesanak Wewa","Mālō e lelei","arùnsawat kráb","Dev Tuka Boro Dis Divum","Bun ghjiornu","Nde-ewo","Salam Alaykum","Selamat pagi","Tālofa","Endemn adderu","Sabahiniz Xeyr","Zao shang hao","Tere","Avuxeni","Namaskara","Talofa lava","Hiya","Kedamtookh brikhta","Sawubona","Grüezi","Subha Ba-khair","Salama","Maayong buntag!","Sahar de pa Khair","Iterluarit","Sawasdee","Dobré ráno","Subha prabhat","Bonjour","Xu Probhaat","Saluton","Dia duit ar maidin","Labrit","Hallo","Good morning","Good Morning","Sat Sri Akaal","Dumela","guten Morgen","Goeie moarn","A Gutn Tog","Gódan daginn","Ola","sabah al-khair","Naigbia","Dader diak","Geia (γεια)","Goedemorgen","Halò","Tashi Delek","Suprabhatham","Zdravo","Shu-probhaat","Dumela","Dobro jutro","G’day","Dobraye ootra","God morgon","Beyani bash","Dobri ranok","Mayap a abak","bom dia","Hello","Għodwa it-tajba","Dobré ráno","Jambo","Nee haow","Bari luys","Dobray ranitsy","Shubh prabhat","Magandang umaga po","Sabaidee","Mwadzuka bwanji","Bona dia","Sob Bakhaer","Gau cha","Nóng gō","Oli yah","Moghrey mie","Mirëmëngjes","Sawubona","Mingalaba","Yasetel liesbukh","Baajjaveri hedhuneh","Guten Morgen","Merhaba","Moni","Hello","Naimbag nga Aldaw","Magandang umaga","Ata marie","Goeie morgen","Aroon-Sawass","yá’át’ééh abíní","Namaste","Xin Chào","Salām","Mwauka tyani","Sabah-il-kheir","Spede bash","Selam","Kairly Tan","Boker tov","Ertiringiz haiyirli bolsun","Wasuze otyano","Assalam u Alaikum","Hola","Moien","Mwabuka buti","Ya’at’eeh","Dobro utro","Ia Orana","Sannu","Ia ora na","Servus","Subax wanaagsan","Bonjou","Ohayo gozaimaz","Slav","Nakasubasi","Bore da","buongiorno","Bonjour","bonan matenon","Aloha kakahiaka","ohayō","Konichiwa","Subh Prabhat","Salam","sobh bekheir","Kamusta","Sa Yadra","Dobro jutro","Öglouny mend","Ayubowan","Guten tag","Marhabaan","Wa lalapo","Kaalai Vannakkam","Good morning","Hallo","Suprabhat","Oyawore","Maayong adlaw","Vanakkam","God morgen","Mangwanani"].freeze
AVAILABLE_EXPENSE_SIZES = [3, 4].to_set.freeze

class Settings
  def self.app
    @app ||= ::YAML.load_file('config/application.yml', aliases: true, symbolize_names: true)[env]
  end

  def self.env
    @env ||= (ENV['RACK_ENV'] || 'development').to_sym
  end
end

Telegram::Bot::Client.run(Settings.app[:telegram_token]) do |bot|
  bot.listen do |message|
    if message.text == '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "#{GREETINGS.sample}, #{message.from.first_name}!\n#{FORMAT_MESSAGE}")
    elsif AVAILABLE_EXPENSE_SIZES.include?(message.text.split(';').count)
      amount, currency, category, place = message.text.split(';')
      event = { user_name: message.from.username,
                amount: amount,
                currency: currency,
                category: category,
                place: place }
      response = RestClient.post(Settings.app[:google_cloud_function_url], { spend_event: event }.to_json, { context_type: :json })
      bot.api.send_message(chat_id: message.chat.id, text: (JSON.parse(response.body)['message'] rescue 'Event cannot be processed'))
    else
      bot.api.send_message(chat_id: message.chat.id, text: "Wrong format! #{FORMAT_MESSAGE}")
    end
  end
end
