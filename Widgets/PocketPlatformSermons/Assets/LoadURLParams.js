window.addEventListener('widgetLoaded', (event) => {
    const urlParams = new URLSearchParams(window.location.search);
    const widget = document.querySelector(`#${event.detail.widgetId}`);

    const loadParams = {};
    let doReload = false;

    const currentParams = widget.getAttribute('data-params').split('&');
    currentParams.forEach(param => {
        const [key, value] = param.split('=');
        loadParams[key] = value;
    });

    urlParams.forEach((value, key) => {
        const newKey = `@${key}`;
        if (loadParams[newKey] !== value) {
            loadParams[`@${key}`] = value;
            doReload = true;
        }
    });

    if (doReload) {
        widget.setAttribute('data-params', Object.entries(loadParams).map(([key, value]) => `${key}=${value}`).join('&'));
        window.ReInitWidget(event.detail.widgetId);
    }
})

function changePage(widgetId, newPage) {
    // Get the widget element
    const widget = document.querySelector(`#${widgetId}`);
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