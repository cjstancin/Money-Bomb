require 'gosu'


module ZOrder
    BACKGROUND, GROUND, COINS, PLAYER, LOSE, UI = *0..5
end
class Tutorial < Gosu::Window
    def initialize
        super 640, 480
        self.caption = "Money Bomb"

        @background_image = Gosu::Image.new("bg.jpg", :tileable => true)
        
        @ground = Gosu::Image.new("pxl.png")

        @player = Player.new

        @coin = Gosu::Image.new("coin.png")
        @coins = Array.new

        @bcoin = Gosu::Image.new("bcoin.png")
        @bcoins = Array.new 

        @bomb = Gosu::Image.new("bomb.png")
        @bombs = Array.new

        @music = Gosu::Song.new("music.wav")

        @lose = Gosu::Song.new("death.wav")

        @font = Gosu::Font.new(10)
        @font_UI = Gosu::Font.new(20)
    end
    def update
        if Gosu.button_down? Gosu::KB_A or Gosu::button_down? Gosu::GP_LEFT
            @player.accel
            @player.move_left
        end
        if Gosu.button_down? Gosu::KB_D or Gosu::button_down? Gosu::GP_RIGHT
            @player.accel
            @player.move_right
        end

        if Gosu.button_down? Gosu::KB_ESCAPE
            close
        end
        
        if Gosu.button_down? Gosu::KB_SPACE
            initialize
        end

        if rand(100) < 10 and @coins.size < 20
            @coins.push(Coin.new(@coin))
        end

        if rand(500) < 4 and @bcoins.size < 10
            @bcoins.push(BCoin.new(@bcoin))
        end
            
        if @player.lives == 3
            if rand(100) < 8 and @bombs.size < 10
                @bombs.push(Bomb.new(@bomb))
            end
        elsif @player.lives == 2
            if rand(200) < 6 and @bombs.size < 7
                @bombs.push(Bomb.new(@bomb))
            end
        elsif @player.lives == 1
            if rand(200) < 4 and @bombs.size < 5
                @bombs.push(Bomb.new(@bomb))
            end
        end

        if !(@player.lives <= 0) 
            @coins.each {|coin| coin.fall}
            @bcoins.each {|bcoin| bcoin.fall}
            @player.collect_coins(@coins)
            @bombs.each { |bomb| bomb.fall}
            @player.collect_bombs(@bombs)
            @player.collect_bcoin(@bcoins)
            @music.play
        end
    end

    def draw
        if @player.lives > 0
            @player.draw
            @coins.each { |coin| coin.draw }
            @bombs.each { |bomb| bomb.draw }
            @bcoins.each { |bcoin| bcoin.draw }
        end
        @ground.draw(0, 430, ZOrder::GROUND)
        @background_image.draw(0, 0, ZOrder::BACKGROUND)
        @font_UI.draw_text("Score: #{@player.score}", 10 , 0, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
        @font_UI.draw_text("Lives: #{@player.lives}", 10 , 15, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
        @font_UI.draw_text("Click Esc to quit", 500 , 0, ZOrder::UI, 1.0, 1.0, Gosu::Color::YELLOW)
        if @player.lives <= 0
            @font.draw_text("
            GAME OVER 
            CLICK SPACE TO RESTART
            CLICK ESC TO LEAVE 
            FINAL SCORE: #{@player.score}", 150, 0, ZOrder::UI, 2.0, 10.0, Gosu::Color::WHITE)
            @lose.play
        end
    end
end

class Player
    attr_reader :score

    def initialize
        @image = Gosu::Image.new("roblox.png")
        @score = 0
        @lives = 3
        @x = 0
        @vel_x = 0
        @y = 400
    end

    def accel
        @vel_x += 0.2
    end

    def move_left
        @x -= @vel_x
        @x %= 640
        @vel_x *= 0.98

    end

    def move_right
        @x += @vel_x
        @x %= 640
        @vel_x *= 0.98
    end

    def score
        @score
    end

    def lives
        @lives
    end

    def draw
        @image.draw(@x, 360, ZOrder::PLAYER, factor_x = 0.2, factor_y = 0.2)
    end

    def collect_coins(coins)
        coins.reject! do |coin|
            if Gosu.distance(@x, @y, coin.x, coin.y) < 60
                @score += 10
                true
            elsif coin.y > 400
                true
            else
                false
            end
        end
    end

    def collect_bombs(bombs)
        bombs.reject! do |bomb|
            if Gosu.distance(@x, @y, bomb.x, bomb.y) < 60
                @lives -= 1
                true
            elsif bomb.y > 400
                true
            else
                false
            end
        end
    end

    def collect_bcoin(bcoins)
        bcoins.reject! do |bcoin|
            if Gosu.distance(@x, @y, bcoin.x, bcoin.y) < 75
                @score += 100
                true
            elsif bcoin.y > 400
                true
            else
                false
            end
        end
    end
end

class Coin
    attr_reader :x, :y

    def initialize(picture)
        @picture = picture
        @x = rand * 640
        @y = 0
        @vel_y = (rand(4..8))
    end

    def draw
       @picture.draw(@x,@y,ZOrder::COINS)
    end

    def fall
        @y += @vel_y
    end
end

class BCoin
    attr_reader :x, :y

    def initialize(picture)
        @picture = picture
        @x = rand * 640
        @y = 0
        @vel_y = (rand(8..10))
    end

    def draw
       @picture.draw(@x,@y,ZOrder::COINS)
    end

    def fall
        @y += @vel_y
    end
end

class Bomb
    attr_reader :x, :y

    def initialize(picture)
        @picture = picture
        @x = rand * 640
        @y = 0
        @vel_y = (rand(2..8))
    end

    def draw
       @picture.draw(@x,@y,ZOrder::COINS)
    end

    def fall
        @y += @vel_y
    end

end


Tutorial.new.show