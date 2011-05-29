module('Validate Nested Form', {
  setup: function() {
    window['new_user'] = {
      type: 'NestedForm::Builder',
      input_tag: '<div class="field_with_errors"><span id="input_tag" /><label for="user_name" class="message"></label></div>',
      label_tag: '<div class="field_with_errors"><label id="label_tag" /></div>',
      validators: {
        'user[name]':
          {"presence":{"message": "must be present"}}
      },
      blueprint_validators: {
        'user[projects_attributes][new_projects][title]':
          {"presence":{"message":"must be present"}}
      }
    }

    $('#qunit-fixture')
      .append($('<form />', {
        action: '/users',
        'data-validate': true,
        method: 'post',
        id: 'new_user'
      }))
      .find('form')
        .append($('<input />', {
          name: 'user[name]',
          id: 'user_name',
          'data-validate': 'true',
          type: 'text'
        }))
        .append($('<label for="user_name">Name</label>'))
        .after($('<div id="project_fields_blueprint"></div>')
          .append($('<div class="fields" />')
            .append($('<input />', {
              name: 'user[projects_attributes][new_projects][title]',
              id: 'user_projects_attributes_new_projects_title',
              'data-validate': true,
              type: 'text'
            }))
            .append($('<label></label>', {
              'for': 'user_projects_attributes_new_projects_title'
            }))));
    $('form#new_user').validate();
  }
});

asyncTest('Validate form after adding nested input', 4, function() {
  var form = $('form#new_user');
  var blueprint_fields = $('#project_fields_blueprint .fields');
  var fields = blueprint_fields.clone().appendTo(form);
  var input = fields.find('input')
    .attr({
      name: 'user[projects_attributes][new_9286424][title]',
      id: 'user_projects_attributes_new_9286424_title'
    });
  var label = fields.find('label')
    .attr({
      'for': 'user_projects_attributes_new_9286424_title'
    });

  form.trigger('submit');
  setTimeout(function() {
    start();
    ok(input.parent().hasClass('field_with_errors'));
    ok(label.parent().hasClass('field_with_errors'));
    ok(input.parent().find('label:contains("must be present")')[0]);
    ok(!$('iframe').contents().find('p:contains("Form submitted")')[0]);
  }, 30);
});


asyncTest('Validate form with invalid form', 4, function() {
  var form = $('form#new_user'), input = form.find('input#user_name');
  var label = $('label[for="user_name"]');

  form.trigger('submit');
  setTimeout(function() {
    start();
    ok(input.parent().hasClass('field_with_errors'));
    ok(label.parent().hasClass('field_with_errors'));
    ok(input.parent().find('label:contains("must be present")')[0]);
    ok(!$('iframe').contents().find('p:contains("Form submitted")')[0]);
  }, 30);
});

asyncTest('Validate form with valid form', 1, function() {
  var form = $('form#new_user'), input = form.find('input#user_name');
  input.val('Test');

  form.trigger('submit');
  setTimeout(function() {
    start();
    ok($('iframe').contents().find('p:contains("Form submitted")')[0]);
  }, 30);
});

asyncTest('Validate form with an input changed to false', 1, function() {
  var form = $('form#new_user'), input = form.find('input#user_name');
  input.val('Test');
  input.attr('changed', false);
  input.attr('data-valid', true);

  form.trigger('submit');
  setTimeout(function() {
    start();
    ok($('iframe').contents().find('p:contains("Form submitted")')[0]);
  }, 30);
});

