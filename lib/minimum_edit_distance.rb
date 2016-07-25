require "minimum_edit_distance/version"

class MinimumEditDistance
  COST_ADD = COST_DELETE = COST_DIFFERENT_REPLACE = 1

  COST_EQUAL_REPLACE = 0

  ACTIONS = [
      ACTION_REPLACE       = :replace,
      ACTION_EQUAL_REPLACE = :equal_replace,
      ACTION_DELETE        = :delete,
      ACTION_ADD           = :add
  ]

  ACTION_CHARS = {
    ACTION_REPLACE       => '*',
    ACTION_EQUAL_REPLACE => ' ',
    ACTION_DELETE        => '-',
    ACTION_ADD           => '+'
  }

  def initialize(str_1, str_2)
    @str_1 = str_1
    @str_2 = str_2
  end

  def minimal_edits
    return edits unless edits.nil?

    fill_matrix
    fill_edits

    edits.reverse
  end

  def print_minimal_edits
    line = 1

    minimal_edits.each do |item|
      chars = case item[:action]
      when ACTION_REPLACE
        "#{ item[:char_1] }|#{ item[:char_2]}"
      when ACTION_EQUAL_REPLACE, ACTION_DELETE, ACTION_ADD
        "#{ item[:char] }"
      end

      print "#{ line } #{ ACTION_CHARS[item[:action]] } #{ chars }\n"

      line += 1
    end
  end

  private

  attr_reader :str_1, :str_2
  attr_accessor :edits

  def fill_edits
    self.edits = []

    i = row_size - 1
    j = column_size - 1

    return [] if i.zero? && j.zero?

    begin
      begin
        action = action_name(i, j)
        i, j = index_step_for_action(action, i, j)
        item_edit = item_edit_for(action, i, j)
        edits.push(item_edit)
      end while j != 0
    end while i != 0
  end

  def item_edit_for(action, i, j)
    case action
    when ACTION_DELETE
      { action: action, char: str_1[i] }
    when ACTION_EQUAL_REPLACE
      { action: action, char: str_1[i] }
    when ACTION_ADD
      { action: action, char: str_2[j] }
    when ACTION_REPLACE
      { action: action, char_1: str_1[i], char_2: str_2[j] }
    else
      raise(
        StandardError,
        "Can not detirmenate item_edit for action=#{ action } i=#{ i }, j=#{ j }"
      )
    end
  end

  def matrix
    @matrix ||= Array.new(row_size) { Array.new(column_size, 0) }
  end

  def costs
    @costs ||= Array.new(row_size) { Array.new(column_size, nil) }
  end

  def column_size
    str_2.size + 1
  end

  def row_size
    str_1.size + 1
  end

  def column_indexes
    @column_indexes ||= (1...column_size).to_a
  end

  def row_indexes
    @row_indexes ||= (1...row_size).to_a
  end

  #
  # Pseudo code:
  #
  # D(0,0) = 0
  # for j from 1 to N
  #   D(0,j) = D(0,j-1) + cost insert a character S2[j]
  # for i from 1 to M
  #   D(i,0) = D(i-1,0) + cost delete a character S1[i]
  #   for j from 1 to N
  #     D(i,j) = min(
  #        D(i-1, j)   + cost delete a character S1[i],
  #        D(i, j-1)   + cost insert a character S2[j],
  #        D(i-1, j-1) + cost replace a character S1[i] on character S2[j]
  #     )
  # return D(M,N)
  #
  def fill_matrix
    column_indexes.each do |j|
      matrix[0][j] = cost_add(0, j)
    end

    row_indexes.each do |i|
      matrix[i][0] = cost_delete(i, 0)

      column_indexes.each do |j|
        matrix[i][j] = cost_action(i, j)
      end
    end
  end

  def index_step_for_action(action, i, j)
    case action
    when ACTION_DELETE
      i -=1
    when ACTION_ADD
      j -=1
    when ACTION_REPLACE, ACTION_EQUAL_REPLACE
      i -=1
      j -=1
    else
      raise(
        StandardError,
        "Can not detirmenate step_for_action for action=#{ action } i=#{ i }, j=#{ j }"
      )
    end

    [i, j]
  end

  def action_name(i, j)
    cost = cost_action(i, j)

    if cost == cost_delete(i, j)
      ACTION_DELETE
    elsif cost == cost_add(i, j)
      ACTION_ADD
    elsif cost == cost_equal_replace(i, j)
      ACTION_EQUAL_REPLACE
    elsif cost == cost_different_replace(i, j)
      ACTION_REPLACE
    else
      raise(
        StandardError,
        "Can not detirmenate action for i=#{ i }, j=#{ j }, matrix=#{ matrix }"
      )
    end
  end

  def cost_action(i, j)
    costs[i][j] ||= [cost_delete(i, j), cost_add(i, j), cost_replace(i, j)].min
  end

  def cost_delete(i, j)
    matrix[i - 1][j] + COST_DELETE
  end

  def cost_add(i, j)
    matrix[i][j - 1] + COST_ADD
  end

  def chars_equal?(i, j)
    str_1[i - 1] == str_2[j - 1]
  end

  def cost_replace(i, j)
    chars_equal?(i, j) ? cost_equal_replace(i, j) : cost_different_replace(i, j)
  end

  def cost_equal_replace(i, j)
    matrix[i - 1][j - 1] + COST_EQUAL_REPLACE
  end

  def cost_different_replace(i, j)
    matrix[i - 1][j - 1] + COST_DIFFERENT_REPLACE
  end
end
