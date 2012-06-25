/*
# This file is part of the OpenWISP Manager
#
# Copyright (C) 2012 OpenWISP.org
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

// dynamic relations (add / remove children)
// it will probably be refactored for a better abstraction to work in more cases
(function(){
    // cache some stuff
    var $container = $('#vap_templates'),
        // elements in this case fieldsets
        $els = $container.find('fieldset'),
        // HTML tags on which attributes need to be updated
        childElementSelector = 'input,select,textarea,label,',
        prefix1 = 'radio_template_vap_templates_attributes',
        prefix2 = 'radio_template\\[vap_templates_attributes\\]',
        // store last element to use as template
        $template = $els.eq($els.length-1);

    var updateElementIndex = function(elem, prefix1, prefix2, ndx) {
        // regular expression for ids and fors, eg: radio_0_
        var idRegex1 = new RegExp(prefix1 + '_(\\d+|__prefix__)_'),
            replacement1 = prefix1 + '_' + ndx + '_',
            // regular expression for names radio[0]
            idRegex2 = new RegExp(prefix2 + '\\[(\\d+|__prefix__)\\]'),
            replacement2 = prefix2.replace(/\\/g, '') + '[' + ndx + ']';
        // replace matched string
        if (elem.attr("for")) elem.attr("for", elem.attr("for").replace(idRegex1, replacement1));
        if (elem.attr('id')) elem.attr('id', elem.attr('id').replace(idRegex1, replacement1));
        if (elem.attr('name')) elem.attr('name', elem.attr('name').replace(idRegex2, replacement2));
    };

    var cloneTemplate = function(options){
        // cache some stuff
        var container = options.container,
            elements = container.find(options.elements),
            order = (options.order) ? options.order : 'insertAfter';
            // last element will be our template
            template = elements.eq(elements.length-1),
            // clone template
            row = template.clone().removeClass('initial'),
            childElementSelector = 'input,select,textarea,label';
        // insert in the DOM: insertBefore or insertAfter
        row[order](template);
        // update elements jquery collection
        elements = container.find(options.elements);

        // retrieve the element we just added, if we used insertAfter is the last one, otherwise if we used insertBefore is going to be the one before the last one
        var minus = (order == 'insertAfter') ? 1 : 2,
            last = elements.eq(elements.length-minus);
        // clean eventual errors and values
        last.find('.fieldWithErrors').removeClass('fieldWithErrors');
        last.find(childElementSelector).val('');

        // update name attributes of all the elements to respect the new order
        // for each element loop over
        elements.each(function(i, el){
            // index is the number that we'll substitute to the attributes of the inputs, ecc.
            var index = i;
            // for each input, select, textarea or label loop over
            $(el).find(childElementSelector).each(function(i, el){
                // retrieve jquery object of current element
                el = $(el);
                // update name, for and id attributes to reflect current status
                updateElementIndex(el, prefix1, prefix2, index);
            });
        });
        // if last inserted element is visible we should hide it
        if(last.is(':visible')){
            last.hide();
        }
        // otherwise we show it and we apply the class 'added' to it
        else{
            last.addClass('added');
            last.show(300);
        }
        return last;
    };

    // if we are not trying to submit a form that returned some errors just hide the template
    if($template.find('.fieldWithErrors').length < 1 && !$template.hasClass('initial')){
        $template.hide();
    }
    // otherwise create the correct template with cleaned errors
    else{
        $template = cloneTemplate({
           container: $container,
           elements: 'fieldset'
        });
        // scroll to first error
        var offset = $container.find('.fieldWithErrors').eq(0).parent().offset();
        $('html,body').animate({scrollTop: offset.top});
    }

    // append remove link in the right place depending if is an existing item or a new one
    var remove_link = '<a class="remove" href="#">'+window.i18n.remove+'</a>';
    $container.find('fieldset').each(function(i, el){
        var $el =  $(el);
        var destroy = $el.find('.destroy');
        if(destroy.length > 0){
            destroy.find('input, label').hide().parent().append(remove_link);
        }
        else{
            $el.append(remove_link);
        }
    });

    // append add link at the end of the form and bind click event
    $container.append('<a class="add" href="#">'+window.i18n.add+'</a>').find('.add').click(function(e){
        e.preventDefault();
        // cache some stuff
        var $this = $(this),
            $els = $container.find('fieldset'),
            // we'll use last fieldset as a template for future additions
            $template = $els.eq($els.length-1);
            // we add the "added" class to the fieldset
        var $row = $template.clone().addClass('added'),
            index = $els.length,
            // determine maximum children that can be added depending on the value of driver field
            // maximum 4 children in case of madwifi, else 12
            maximum = ($('#radio_template_driver').val() == 'madwifi-ng') ? 4 : 12;
        // if maximum is reached alert a message and interrupt the execution of this function
        if($container.find('fieldset:visible').length >= maximum){
            alert(window.i18n.maximumVapError);
            return;
        }
        cloneTemplate({
            container: $container,
            elements: 'fieldset',
            order: 'insertBefore'
        });
    });

    // if no vap templates are visible add 1
    if($container.find('fieldset:visible').length < 1){
        $container.find('a.add').trigger('click');
    }

    // bind click event using live for future added elements
    $container.find('.remove').live('click', function(e){
        e.preventDefault();
        var $this = $(this);
        var checkbox = $this.parent().find('input[type=checkbox]');
        // if it's a pre existent row just hide
        if(checkbox.length > 0){
            checkbox.attr('checked', true);
            checkbox.parent().parent().hide(300);
        }
        // if it's a new row remove from DOM
        else{
            $this.parent().hide(300, function(){
                // when hiding animation is finished remove the element from the DOM
                $this.parent().remove();
            });
        }
    });
    // hide elements that have been marked as removed but are still showing in the HTML, usually because the form did not validate
    $('.destroy input:checked').parent().find('.remove').trigger('click');
})();
