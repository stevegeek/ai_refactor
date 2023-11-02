You are an expert Ruby senior software developer.

You will be writing the type signatures for the Ruby code below, in RBS format.

RBS is a language to describe the structure of Ruby programs. You can write down the definition of a class or module: methods defined in the class, instance variables and their types, and inheritance/mix-in relations. It also allows declaring constants and global variables.

The following is a small example of RBS for a chat app.

Given the Ruby
```ruby
module ChatApp
  VERSION = "1.0.0"
  class User
    attr_reader :login, :email
    
    def initialize(login:, email:); end
      
    def my_method(String arg1, Integer arg2); end
  end
  
  class Bot
    attr_reader :name
    attr_reader :email
    attr_reader :owner

    def initialize(name:, owner:); end
  end

  class Message
    attr_reader :id, :string, :from, :reply_to

    def initialize(from:, string:); end

    def reply(from:, string:)
      Message.new(from, string)
    end
  end

  class Channel
    attr_reader :name, :messages, :users, :bots

    def initialize(name)
      @name = name
      @messages = []
      @users = []
      @bots = []
    end

    def each_member(&block)
      members = users + bots
      block? ? members.each(&block) : members.each
    end
  end
end
```

We can write the RBS as follows:
```
module ChatApp
  VERSION: String

  class User
    attr_reader login: String
    attr_reader email: String

    # If a method takes keyword arguments then use `key: Type` syntax.
    def initialize: (login: String, email: String) -> void
    
    # If a method takes positional arguments then put the type before the argument name.
    def my_method: (String arg1, Integer arg2) -> String
  end

  class Bot
    attr_reader name: String
    attr_reader email: String
    attr_reader owner: User

    def initialize: (name: String, owner: User) -> void
  end

  class Message
    attr_reader id: String
    attr_reader string: String
    attr_reader from: User | Bot                     # `|` means union types: `#from` can be `User` or `Bot`
    attr_reader reply_to: Message?                   # `?` means optional type: `#reply_to` can be `nil`

    def initialize: (from: User | Bot, string: String) -> void

    def reply: (from: User | Bot, string: String) -> Message
  end

  class Channel
    attr_reader name: String
    attr_reader messages: Array[Message]
    attr_reader users: Array[User]
    attr_reader bots: Array[Bot]

    def initialize: (String name) -> void

    def each_member: () { (User | Bot) -> void } -> void  # `{` and `}` means block.
                   | () -> Enumerator[User | Bot, void]   # Method can be overloaded.
  end
end
```

Do not include comments in your RBS code or start the file with 'rbs' or '.rbs'.

__{{context}}__

__{{prompt_header}}__

The input file is: __{{input_file_path}}__
The output file path is: __{{output_file_path}}__

__{{prompt_footer}}__
