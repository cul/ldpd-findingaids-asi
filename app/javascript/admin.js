const csrfParam = document.querySelector('meta[name="csrf-param"]');
const csrfToken = document.querySelector('meta[name="csrf-token"]');

const refreshResourceForm = document.getElementById('refresh-resource-form');
if (refreshResourceForm) {
  refreshResourceForm.addEventListener('submit', (e) => {
    e.preventDefault();
    const { action, method } = e.target;
    const resourceRecordUri = document.getElementById('resource_record_uri');
    const includeUnpublished = document.getElementById('include_unpublished');

    fetch(action, {
      method,
      // credentials: 'include', // TODO: Might uncomment this later if needed
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        [csrfParam]: csrfToken,
        resource_record_uri: resourceRecordUri,
        include_unpublished: includeUnpublished,
      }),
    });
  });
}
