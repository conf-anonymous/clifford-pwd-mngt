module Clifford
  class Password

    attr_accessor :x1, :x2, :p1, :p2, :value, :order, :level, :counter

    def initialize
      @counter = 0
      # puts "@counter = #{@counter}"
      @order = (0..15).to_a.shuffle
      # puts "@order = #{@order}"
      generate_internal_multivectors
      # puts "@x1 = #{x1}"
      # puts "@x2 = #{x2}"
    end

    def generate_password(level = 1)
      @level = level
      @counter += 1
      # puts "@level = #{@level}"
      # puts "@counter = #{@counter}"
      generate_p1_and_p2
      multivector_to_printable_characters
    end

    def generate_invertible_random_multivector
      m = nil
      while true
        m = Clifford::Multivector3DMod.new Array.new(8){ rand(0..126) }, 127
        break if m.rationalize.data != [0,0,0,0,0,0,0,0]
      end
      m
    end

    def check_for_special_characters
      (@p1.data & ((33..37).to_a + (123..126).to_a)).size > 0 || (@p2.data & ((33..37).to_a + (123..126).to_a)).size > 0
    end

    def check_for_numbers
      (@p1.data & (48..57).to_a).size > 0 || (@p2.data & (48..57).to_a).size > 0
    end

    def check_for_uppercase_letters
      (@p1.data & (65..90).to_a).size > 0 || (@p2.data & (65..90).to_a).size > 0
    end

    def check_for_lowercase_letters
      (@p1.data & (97..122).to_a).size > 0 || (@p2.data & (97..122).to_a).size > 0
    end

    def check_for_valid_characters
      @p1.data.min >= 33 && @p1.data.max <= 126 && @p2.data.min >= 33 && @p2.data.max <= 126
    end

    def generate_internal_multivectors
      @x1,@x2 = Array.new(4){ generate_invertible_random_multivector }
    end

    def validate_password_multivectors
      [
        check_for_special_characters,
        check_for_numbers,
        check_for_uppercase_letters,
        check_for_lowercase_letters,
        check_for_valid_characters
      ]
    end

    def generate_p1_and_p2
      d1 = nil
      d2 = nil
      while true
        d1_data = [@counter, Tools.mod_inverse(@level,127)] + Array.new(6){ rand(0..126)}
        d2_data = [@level, Tools.mod_inverse(@counter,127)] + Array.new(6){ rand(0..126)}

        d1 = Clifford::Multivector3DMod.new d1_data, 127
        d2 = Clifford::Multivector3DMod.new d2_data, 127

        @p1 = @x1.gp(d1).gp(@x1)
        @p2 = @x2.gp(d2).gp(@x2)

        validations = validate_password_multivectors

        break if validations.uniq == [true]
      end

      # puts "d1 = #{d1}"
      # puts "d2 = #{d2}"
      #
      # puts "@p1 = #{p1}"
      # puts "@p2 = #{p2}"
    end

    def multivector_to_printable_characters
      array = (@p1.data + @p2.data).values_at(*order)
      # puts "array = #{array}"
      @value = array.map{|number| number.chr}.join
    end

    def recover_p1_p2(value)
      data = value.each_byte.to_a.map.with_index{|a,i| [a,@order[i]]}.sort_by{|a| a[1]}.map{|a| a[0]}
      p1_r = Clifford::Multivector3DMod.new data[0..7], 127
      p2_r = Clifford::Multivector3DMod.new data[8..15], 127
      [p1_r, p2_r]
    end

    def verify_password(given_value)
      p1_r, p2_r = recover_p1_p2(given_value)

      d1 = @x1.inverse.gp(p1_r).gp(@x1.inverse)
      d2 = @x2.inverse.gp(p2_r).gp(@x2.inverse)

      counter_r = d1.e0
      level_r = d2.e0
      valid = (d1.e1 == Tools.mod_inverse(level_r,127)) && (d2.e1 == Tools.mod_inverse(counter_r,127))

      [valid, counter_r, level_r]
    end

  end
end
