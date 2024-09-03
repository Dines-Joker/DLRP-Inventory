$(document).ready(function () {

//   $('.container').css('display', 'block');
    
//   AddItem('1', 'item1', 10, 5, 'Test Item', 'Test Label', false, true, 'https://via.placeholder.com/50', true);

  var data = {
      showfav: false,
  };

  // Toggle favorite functionality
  function togglefav2() {
      if (data.showfav) {
          data.showfav = false;
          $("#ss").css("color", "white");
          $(".test").hide();
      } else {
          data.showfav = true;
          $("#ss").css("color", "red");
          $(".test").show();
      }
  }

  // Search functionality for filtering inventory items
  $(".inputs").keyup(function () {
      var filter = $(this).val().toLowerCase();
      $('.inv-cont-elem').each(function () {
          var text = $(this).text().toLowerCase();
          if (text.indexOf(filter) < 0) {
              $(this).hide();
          } else {
              $(this).show();
          }
      });
  });

  // Event listeners for various actions from external events
  window.addEventListener('message', function (event) {
      if (event.data.action == 'open') {
          $('.container').css('display', 'block');
          $('.container2').css('display', 'block');
      } else if (event.data.action == 'close') {
          $('.container').css('display', 'none');
          $('.container2').css('display', 'none');
      } else if (event.data.action == 'add') {
          addItem(event.data);
      } else if (event.data.action == 'addw') {
          addWeapon(event.data);
      } else if (event.data.action == 'reset') {
          resetInventory(event.data);
      } else if (event.data.action == 'updatemax') {
          updateMax(event.data);
      } else if (event.data.action == 'update') {
          $('.inv-head-btn p').text(event.data.money + '$');
      }
  });

  // Add item to inventory
  function addItem(data) {
      if (data.count <= 0) return;

      $('#invcontainer').append(`
          <div class="inv-cont-elem" onclick="select(this);" 
               data-itype="item" 
               data-identifier="${data.identifier}" 
               data-limit="${data.limit}" 
               data-item="${data.item}" 
               data-count="${data.count}" 
               data-name="${data.name}" 
               data-label="${data.label}" 
               data-rare="${data.rare}" 
               data-can_remove="${data.can_remove}" 
               data-url="${data.url}" 
               data-useable="${data.useable}">
              <img class="items" src="${data.url}">
              <div class="kreis">
                  <p class="anzahl">${data.count}</p>
              </div>
              <span class="tooltiptext2">${data.label}</span>
          </div>
      `);
  }

  // Add weapon to inventory
  function addWeapon(data) {
      if (data.count <= -1) return;

      $('#invcontainer').append(`
          <div class="inv-cont-elem" onclick="select3(this);" 
               data-itype="weapon" 
               data-identifier="${data.identifier}" 
               data-limit="${data.limit}" 
               data-item="${data.item}" 
               data-count="${data.count}" 
               data-name="${data.name}" 
               data-label="${data.label}" 
               data-rare="${data.rare}" 
               data-can_remove="${data.can_remove}" 
               data-url="${data.url}" 
               data-useable="${data.useable}">
              <img class="items" src="${data.url}">
              <div class="kreis">
                  <p class="anzahl">${data.count}</p>
              </div>
              <span class="tooltiptext2">${data.label}</span>
          </div>
      `);
  }

  // Reset inventory
  function resetInventory(data) {
      $("#invcontainer").empty();
      $('.inv-head-btn p').text('');

      if (data.money >= 1) {
          $('#invcontainer').append(`
              <div class="inv-cont-elem" id="element-money" onclick="select2(this);" data-itype="cash" data-count="${data.money}">
                  <img class="items" src="https://i.ibb.co/gtksVFy/imageedit-2-3505161766.png">
                  <div class="kreis">
                      <p class="anzahl">${data.money} $</p>
                  </div>
                  <span class="tooltiptext2">Schwarzgeld</span>
              </div>
          `);
      }
  }

  // Update the maximum allowed amount of an item
  function updateMax(data) {
      let max = parseInt($('.selected').attr('data-count')) - data.max;
      $("#amount").attr('max', max);
      $('.selected').attr('data-count', max);
      $('.inv-head-btn p').text(max + 'x');

      if (max <= 0) {
          $('.selected').remove();
      }
  }

  // Event listeners for UI interactions
  $("#close").click(function () {
      $('.container').css('display', 'none');
      $.post('http://mindv_inventory/escape', JSON.stringify({}));
  });

  $("#refresh").click(function () {
      $.post('http://mindv_inventory/refresh', JSON.stringify({}));
  });

  $("#use").click(function () {
      handleItemAction('use');
  });

  $("#throw").click(function () {
      handleItemAction('throw');
  });

  $("#give").click(function () {
      handleItemAction('give');
  });

  // Handle item actions like use, throw, and give
  function handleItemAction(action) {
      let count = $('.selected').attr('data-count');
      let amount = $("#amount").val();
      let type = $('.selected').attr('data-itype');

      if (type === 'item') {
          handleItemChange(action, count, amount);
      } else if (type === 'cash') {
          handleCashChange(action, count, amount);
      } else if (type === 'weapon') {
          handleWeaponChange(action, count, amount);
      }
  }

  function handleItemChange(action, count, amount) {
      let updatedCount = count - amount;
      $('.selected').attr('data-count', updatedCount);
      $("#amount").attr('max', updatedCount);
      postAction(action, updatedCount);
  }

  function handleCashChange(action, count, amount) {
      let updatedCount = count - amount;
      $('.selected').attr('data-count', updatedCount);
      $("#amount").attr('max', updatedCount);
      postAction(action + 'blackcash', updatedCount);
  }

  function handleWeaponChange(action, count, amount) {
      let updatedCount = count - amount;
      $('.selected').attr('data-count', updatedCount);
      $("#amount").attr('max', updatedCount);
      postAction(action + 'weapon', updatedCount);
  }

  function postAction(action, updatedCount) {
      $.post('http://mindv_inventory/' + action, JSON.stringify({
          item: $('.selected').attr('data-name'),
          amount: $("#amount").val(),
          label: $('.selected').attr('data-label'),
      }));
      updateInventoryDisplay(updatedCount);
  }

  function updateInventoryDisplay(updatedCount) {
      $('.inv-head-btn p').text(updatedCount + 'x');
      if (updatedCount <= 0) {
          $('.selected').remove();
      }
  }

  // Handle keyboard events for closing
  document.onkeyup = function (data) {
      if (data.which == 27) { // ESC key
          $.post("http://mindv_inventory/escape", JSON.stringify({}));
      }
  };

  // Prevent non-numeric input for amount
  function isNumberKey(evt) {
      var charCode = (evt.which) ? evt.which : evt.keyCode;
      return !(charCode > 31 && (charCode < 48 || charCode > 57));
  }

  window.onload = () => {
      const amount = document.getElementById('amount');
      amount.onpaste = e => e.preventDefault();
  };
    const invContainer = document.getElementById('invcontainer');

    // Sortable für Drag-and-Drop
    new Sortable(invContainer, {
        animation: 150,
        ghostClass: 'sortable-ghost',
        chosenClass: 'sortable-chosen',
        dragClass: 'sortable-drag',
        onStart: function (evt) {
            evt.from.classList.add('dragging');
        },
        onEnd: function (evt) {
            evt.from.classList.remove('dragging');
        }
    });

    // Beispiel-Funktion zum Hinzufügen von Items (kann angepasst werden)
    function addItem(name, imgSrc, quantity) {
        $('#invcontainer').append(`
            <div class="item-tile" draggable="true">
                <img src="${imgSrc}" alt="${name}">
                <div class="item-info">
                    <p class="item-name">${name}</p>
                    <p class="item-quantity">x${quantity}</p>
                </div>
            </div>
        `);
    }

    // Beispielhafte Items hinzufügen
    addItem('Item 1', 'https://via.placeholder.com/100', 10);
    addItem('Item 2', 'https://via.placeholder.com/100', 5);
    addItem('Item 3', 'https://via.placeholder.com/100', 8);
    addItem('Item 4', 'https://via.placeholder.com/100', 12);
    addItem('Item 5', 'https://via.placeholder.com/100', 3);
    addItem('Item 6', 'https://via.placeholder.com/100', 7);
    addItem('Item 7', 'https://via.placeholder.com/100', 15);
    addItem('Item 8', 'https://via.placeholder.com/100', 20);
    addItem('Item 9', 'https://via.placeholder.com/100', 5);
    addItem('Item 10', 'https://via.placeholder.com/100', 6);
    addItem('Item 11', 'https://via.placeholder.com/100', 11);
    addItem('Item 12', 'https://via.placeholder.com/100', 4);

    // Event Listeners für UI Interaktionen
    $("#close").click(function () {
        $('.container').hide();
        $.post('http://mindv_inventory/escape', JSON.stringify({}));
    });

    $("#refresh").click(function () {
        $.post('http://mindv_inventory/refresh', JSON.stringify({}));
    });

    $("#use").click(function () {
        handleItemAction('use');
    });

    $("#throw").click(function () {
        handleItemAction('throw');
    });

    $("#give").click(function () {
        handleItemAction('give');
    });

    function handleItemAction(action) {
        let count = $('.selected').attr('data-count');
        let amount = $("#amount").val();
        let type = $('.selected').attr('data-itype');

        if (type === 'item') {
            handleItemChange(action, count, amount);
        } else if (type === 'cash') {
            handleCashChange(action, count, amount);
        } else if (type === 'weapon') {
            handleWeaponChange(action, count, amount);
        }
    }

    function handleItemChange(action, count, amount) {
        let updatedCount = count - amount;
        $('.selected').attr('data-count', updatedCount);
        $("#amount").attr('max', updatedCount);
        postAction(action, updatedCount);
    }

    function handleCashChange(action, count, amount) {
        let updatedCount = count - amount;
        $('.selected').attr('data-count', updatedCount);
        $("#amount").attr('max', updatedCount);
        postAction(action + 'blackcash', updatedCount);
    }

    function handleWeaponChange(action, count, amount) {
        let updatedCount = count - amount;
        $('.selected').attr('data-count', updatedCount);
        $("#amount").attr('max', updatedCount);
        postAction(action + 'weapon', updatedCount);
    }

    function postAction(action, updatedCount) {
        $.post('http://mindv_inventory/' + action, JSON.stringify({
            item: $('.selected').attr('data-name'),
            amount: $("#amount").val(),
            label: $('.selected').attr('data-label'),
        }));
        updateInventoryDisplay(updatedCount);
    }

    function updateInventoryDisplay(updatedCount) {
        $('.inv-head-btn p').text(updatedCount + 'x');
        if (updatedCount <= 0) {
            $('.selected').remove();
        }
    }

    document.onkeyup = function (data) {
        if (data.which == 27) { // ESC key
            $.post("http://mindv_inventory/escape", JSON.stringify({}));
        }
    };

    function isNumberKey(evt) {
        var charCode = (evt.which) ? evt.which : evt.keyCode;
        return !(charCode > 31 && (charCode < 48 || charCode > 57));
    }

    window.onload = () => {
        const amount = document.getElementById('amount');
        amount.onpaste = e => e.preventDefault();
    };
    $(document).ready(function () {
    // Kachel anklicken, um sie auszuwählen
    $(document).on('click', '.inv-cont-elem', function () {
        $('.inv-cont-elem').removeClass('selected');
        $(this).addClass('selected');
        updateSelectedInfo(); // Optional, um zusätzliche Informationen anzuzeigen
    });

    // Funktion zum Aktualisieren von Informationen über das ausgewählte Element
    function updateSelectedInfo() {
        var selectedItem = $('.selected');
        if (selectedItem.length) {
            $("#amount").val(1); // Zurücksetzen der Menge auf Standardwert
            $("#amount").attr('max', selectedItem.attr('data-count')); // Setze das maximale Limit
            // Hier kannst du auch andere Informationen über das ausgewählte Element aktualisieren
        }
    }

    // Event Listener für Benutzungsbutton
    $("#use").click(function () {
        handleItemAction('use');
    });

    // Event Listener für Verwerfungsbutton
    $("#remove").click(function () {
        handleItemAction('throw');
    });

    // Funktion zur Handhabung von Item-Aktionen
    function handleItemAction(action) {
        let selectedItem = $('.selected');
        if (selectedItem.length) {
            let count = selectedItem.attr('data-count');
            let amount = $("#amount").val();
            let type = selectedItem.attr('data-itype');

            if (type === 'item') {
                handleItemChange(action, count, amount);
            } else if (type === 'cash') {
                handleCashChange(action, count, amount);
            } else if (type === 'weapon') {
                handleWeaponChange(action, count, amount);
            }
        }
    }

    function handleItemChange(action, count, amount) {
        let updatedCount = count - amount;
        $('.selected').attr('data-count', updatedCount);
        $("#amount").attr('max', updatedCount);
        postAction(action, updatedCount);
    }

    function handleCashChange(action, count, amount) {
        let updatedCount = count - amount;
        $('.selected').attr('data-count', updatedCount);
        $("#amount").attr('max', updatedCount);
        postAction(action + 'blackcash', updatedCount);
    }

    function handleWeaponChange(action, count, amount) {
        let updatedCount = count - amount;
        $('.selected').attr('data-count', updatedCount);
        $("#amount").attr('max', updatedCount);
        postAction(action + 'weapon', updatedCount);
    }

    function postAction(action, updatedCount) {
        $.post('http://mindv_inventory/' + action, JSON.stringify({
            item: $('.selected').attr('data-name'),
            amount: $("#amount").val(),
            label: $('.selected').attr('data-label'),
        }));
        updateInventoryDisplay(updatedCount);
    }

    function updateInventoryDisplay(updatedCount) {
        $('.inv-head-btn p').text(updatedCount + 'x');
        if (updatedCount <= 0) {
            $('.selected').remove();
        }
    }

    // Verhindere die Eingabe von nicht-numerischen Werten in der Menge
    $("#amount").on("keypress", function (e) {
        return isNumberKey(e);
    });

    function isNumberKey(evt) {
        var charCode = (evt.which) ? evt.which : evt.keyCode;
        return !(charCode > 31 && (charCode < 48 || charCode > 57));
    }

    // Verhindere das Einfügen von Werten in die Menge
    $("#amount").on("paste", function (e) {
        e.preventDefault();
    });
});
    

});


