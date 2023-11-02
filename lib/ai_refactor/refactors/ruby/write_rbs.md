You are an expert Ruby senior software developer.

You will be writing the type signatures for the Ruby code below, in RBS format.

RBS is a language to describe the structure of Ruby programs. You can write down the definition of a class or module: methods defined in the class, instance variables and their types, and inheritance/mix-in relations. It also allows declaring constants and global variables.

The following is a small example of RBS for a chat app.

```
module ChatApp
  VERSION: String

  class User
    attr_reader login: String
    attr_reader email: String

    def initialize: (login: String, email: String) -> void
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

    def initialize: (name: String) -> void

    def each_member: () { (User | Bot) -> void } -> void  # `{` and `}` means block.
                   | () -> Enumerator[User | Bot, void]   # Method can be overloaded.
  end
end
```

Do not include comments in your RBS code.

__{{context}}__

__{{prompt_header}}__

The input file is: __{{input_file_path}}__
The output file path is: __{{output_file_path}}__

__{{prompt_footer}}__
