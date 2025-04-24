const csrfParam = document.querySelector('meta[name="csrf-param"]').content;
const csrfToken = document.querySelector('meta[name="csrf-token"]').content;
const refreshResultStatusElement = document.getElementById('refresh-result-status');

const refreshResourceForm = document.getElementById('refresh-resource-form');

if (refreshResourceForm) {
  refreshResourceForm.addEventListener('submit', async (e) => {
    e.preventDefault();
    const { action, method } = e.target;
    const resourceRecordUri = document.getElementById('resource_record_uri').value;
    const includeUnpublished = document.getElementById('include_unpublished').value === 'true';

    refreshResultStatusElement.innerHTML = 'Downloading and reindexing... (this can take a while for large resources)';

    try {
      const response = await fetch(action, {
        method,
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          [csrfParam]: csrfToken,
          resource_record_uri: resourceRecordUri,
          include_unpublished: includeUnpublished,
        }),
      });

      if (response.status !== 200) {
        throw new Error(`Received a response status of ${response.status}`);
      }

      const data = await response.json();

      if (data.result) {
        refreshResultStatusElement.innerHTML = `
          <p class="alert alert-success mt-3">
            Collection reindexed successfully!
            <a href="/archives/${data.resource_id}">View this collection &raquo;</a>
          </p>
        `;
      } else {
        throw new Error(data.error);
      }
    } catch (err) {
      refreshResultStatusElement.innerHTML = `
        <p class="alert alert-danger mt-3">
          <strong>An unexpected error occurred</strong>:<br />${err}
        </p>
      `;
    }
  });
}
