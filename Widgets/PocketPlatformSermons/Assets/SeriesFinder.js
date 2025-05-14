function changePage(widgetId, newPage) {
    // Get the widget element
    const widget = document.querySelector(`[data-component="CustomWidget"]#${widgetId}`);
    if (!widget) return;
    
    // Update the data-params attribute to include the page
    let currentParams = widget.getAttribute('data-params') || '';
    
    // Remove existing page parameter if it exists
    currentParams = currentParams.replace(/@Page=\d+/g, '');
    
    // Add the new page parameter
    if (currentParams) {
        widget.setAttribute('data-params', `${currentParams}&@Page=${newPage}`);
    } else {
        widget.setAttribute('data-params', `@Page=${newPage}`);
    }
    
    // Reinitialize the widget
    window.ReInitWidget(widgetId);
}

function handclick(event) {
    console.log('click');
}

window.addEventListener('widgetLoaded', function(event) {
    console.log('Widget loaded:', event.detail);
});