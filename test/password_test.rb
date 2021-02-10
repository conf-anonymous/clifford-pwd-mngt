require Dir.pwd + "/test/test_helpers"

class TestPassword < Minitest::Test

  def test_initialization
    password = Clifford::Password.new

    assert_equal 0, password.counter
    assert_equal 16, password.order.size
    assert_equal Clifford::Multivector3DMod, password.x1.class
    assert_equal Clifford::Multivector3DMod, password.x2.class
    assert_equal [1,0], password.x1.gp(password.x1.inverse).data.uniq
    assert_equal [1,0], password.x2.gp(password.x2.inverse).data.uniq
  end

  def test_generate_invertible_random_multivector
    password = Clifford::Password.new

    multivectors = Array.new(10){ password.generate_invertible_random_multivector }

    multivectors.each do |m|
      assert_equal [1,0], m.gp(m.inverse).data.uniq
    end
  end

  def test_check_for_special_characters
    valid_entries = (33..37).to_a + (123..126).to_a

    m_valid = Clifford::Multivector3DMod.new [89,125,13,2,9,11,19,22], 127
    m_invalid = Clifford::Multivector3DMod.new [89,122,13,2,9,11,19,22], 127

    intersection_valid = m_valid.data & valid_entries
    intersection_invalid = m_invalid.data & valid_entries

    assert intersection_valid.size > 0
    assert intersection_invalid.size == 0
  end

  def test_check_for_numbers
    valid_entries = (48..57).to_a

    m_valid = Clifford::Multivector3DMod.new [89,125,13,51,9,11,19,22], 127
    m_invalid = Clifford::Multivector3DMod.new [89,122,13,2,9,11,19,22], 127

    intersection_valid = m_valid.data & valid_entries
    intersection_invalid = m_invalid.data & valid_entries

    assert intersection_valid.size > 0
    assert intersection_invalid.size == 0
  end

  def test_check_for_uppercase_letters
    valid_entries = (65..90).to_a

    m_valid = Clifford::Multivector3DMod.new [89,125,13,51,9,11,19,22], 127
    m_invalid = Clifford::Multivector3DMod.new [63,122,13,2,9,11,19,22], 127

    intersection_valid = m_valid.data & valid_entries
    intersection_invalid = m_invalid.data & valid_entries

    assert intersection_valid.size > 0
    assert intersection_invalid.size == 0
  end

  def test_check_for_lowercase_letters
    valid_entries = (97..122).to_a

    m_valid = Clifford::Multivector3DMod.new [100,125,13,51,9,11,19,22], 127
    m_invalid = Clifford::Multivector3DMod.new [63,123,13,2,9,11,19,22], 127

    intersection_valid = m_valid.data & valid_entries
    intersection_invalid = m_invalid.data & valid_entries

    assert intersection_valid.size > 0
    assert intersection_invalid.size == 0
  end

  def test_check_for_valid_characters
    valid_entries = (33..126).to_a

    m_valid = Clifford::Multivector3DMod.new [100,125,42,51,99,54,65,78], 127
    m_invalid = Clifford::Multivector3DMod.new [63,123,13,2,9,11,19,22], 127

    m_valid_min = m_valid.data.min
    m_valid_max = m_valid.data.max

    m_invalid_min = m_invalid.data.min
    m_invalid_max = m_invalid.data.max

    assert (m_valid_min >= valid_entries.min && m_valid_min <= valid_entries.max)
    assert !(m_invalid_min >= valid_entries.min && m_invalid_min <= valid_entries.max)
  end

  def test_validate_password_multivectors
    valid_entries = (33..37).to_a + (123..126).to_a
    valid_entries = (48..57).to_a
    valid_entries = (65..90).to_a
    valid_entries = (97..122).to_a
    valid_entries = (33..126).to_a

    p1_valid = Clifford::Multivector3DMod.new [34,125,56,98,38,110,101,50], 127
    p2_valid = Clifford::Multivector3DMod.new [37,49,66,99,125,103,89,57], 127

    p1_invalid = Clifford::Multivector3DMod.new [34,125,56,98,38,110,101,47], 127
    p2_invalid = Clifford::Multivector3DMod.new [30,49,66,99,125,103,89,57], 127

    password = Clifford::Password.new
    password.p1 = p1_valid
    password.p2 = p2_valid

    validations = password.validate_password_multivectors

    assert_equal [true], validations.uniq

    password.p1 = p1_invalid
    password.p2 = p2_invalid

    validations = password.validate_password_multivectors

    assert ([true] != validations.uniq)

    password = Clifford::Password.new
    password.generate_password

    validations = password.validate_password_multivectors

    assert_equal [true], validations.uniq
  end

  def test_recover_p1_p2
    password = Clifford::Password.new
    value_original = password.generate_password
    p1_original = password.p1
    p2_original = password.p2

    p1_recovered, p2_recovered = password.recover_p1_p2(value_original)

    assert_equal p1_original.data, p1_recovered.data
    assert_equal p2_original.data, p2_recovered.data
  end

  def test_multivector_to_printable_characters
    sample_value = '"-zR<":Y$RC5i3lF'
    password = Clifford::Password.new
    password.x1 = Clifford::Multivector3DMod.new [71, 82, 100, 105, 71, 54, 41, 82], 127
    password.x2 = Clifford::Multivector3DMod.new [49, 117, 63, 74, 73, 119, 16, 24], 127
    password.value = sample_value
    password.p1, password.p2 = password.recover_p1_p2(sample_value)

    assert_equal password.multivector_to_printable_characters, password.value
  end

end
