$:.unshift(File.join(File.dirname(__FILE__), '../lib'))

require 'rubygems'
require 'active_support'
require 'action_controller'
require 'action_view'
require 'test/unit'
require 'filtered_list'

class FilteredListTest < Test::Unit::TestCase
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::JavaScriptHelper
  include FilteredList::Helper

  # Basic list with symbol to retrieve field, label and value
  def test_filter_with_meth
    html = filter %w(a b b c e e f), :to_s
    assert_equal %q{<select class="filter_select" id="filter-to_s" name="filter[to_s]" onchange=";if($('filter_button')) $('filter_button').disabled = false;"><option value=":all">All</option>
<option value="a">a</option>
<option value="b">b</option>
<option value="c">c</option>
<option value="e">e</option>
<option value="f">f</option></select>}, html
  end

  # List with field specified, label and value determined from block
  def test_filter_with_block
    html = filter(%w(a b b c e e f), :ltr) {|o| o.succ}
    assert_equal %q{<select class="filter_select" id="filter-ltr" name="filter[ltr]" onchange=";if($('filter_button')) $('filter_button').disabled = false;"><option value=":all">All</option>
<option value="b" selected="selected">b</option>
<option value="c">c</option>
<option value="d">d</option>
<option value="f">f</option>
<option value="g">g</option></select>}, html
  end

  # List with field specified, label and value determined from block but different
  def test_filter_id_ne_label
    html = filter(%w(a b b c e e f), :ltr) {|o| ['a', o]}
    assert_equal %q{<select class="filter_select" id="filter-ltr" name="filter[ltr]" onchange=";if($('filter_button')) $('filter_button').disabled = false;"><option value=":all">All</option>
<option value="a">a</option>
<option value="b" selected="selected">a</option>
<option value="c">a</option>
<option value="e">a</option>
<option value="f">a</option></select>}, html
  end

  # Button to submit filter
  def test_filter_button
    html = filter_button
    assert_equal %q{<input disabled="disabled" id="filter_button" onclick=";location.href='?boo=baz&amp;foo=bar&amp;' + $$('select.filter_select').inject([], function(m, e) {m.push(e.getAttribute('name') + '=' + encodeURIComponent($F(e))); return m}).join('&amp;')" type="button" value="Apply Filter" />}, html
  end

  private

  # Simulate params from request with filter already set
  def params
    HashWithIndifferentAccess['filter' => {'ltr' => 'b'}, 'foo' => 'bar', 'boo' => 'baz']
  end
end
