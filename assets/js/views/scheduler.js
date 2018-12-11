import $ from 'jquery'
import 'jquery-ui/ui/widgets/sortable'
import 'jquery-ui/ui/widgets/resizable'

$(".sortable").sortable({
  connectWith: ".sortable",
}).disableSelection();

$(".resizable").resizable({
  grid: 10,
  minHeight: 40,
  handles: "s",
});
