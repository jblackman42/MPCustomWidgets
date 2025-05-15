window.addEventListener('widgetLoaded', function(event) {
    const urlParams = new URLSearchParams(window.location.search);
    const seriesId = urlParams.get('SeriesID');
    
    // does series id already exist in the data-params?
    const widget = document.querySelector(`#${event.detail.widgetId}`);
    let currentParams = widget.getAttribute('data-params') || '';
    if (currentParams.includes('SeriesID')) {
        // remove the SeriesID parameter
        currentParams = currentParams.replace('SeriesID', '');
    } else {
        // Add the new page parameter
        if (currentParams) {
            widget.setAttribute('data-params', `${currentParams}&@SeriesID=${seriesId}`);
        } else {
            widget.setAttribute('data-params', `@SeriesID=${seriesId}`);
        }
    
        window.ReInitWidget(event.detail.widgetId);
    }
});