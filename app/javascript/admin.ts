const csrfParam = (document.querySelector('meta[name="csrf-param"]') as HTMLMetaElement)?.content;
const csrfToken = (document.querySelector('meta[name="csrf-token"]') as HTMLMetaElement)?.content;
const refreshResultStatusElement = document.getElementById('refresh-result-status');
const refreshResourceForm = document.getElementById('refresh-resource-form');

interface RefreshResponse {
  result: boolean;
  resource_id?: string;
  error?: string;
}

if (refreshResourceForm) {
  refreshResourceForm.addEventListener('submit', async (e: Event): Promise<void> => {
    e.preventDefault();

    const { action, method } = e.target as HTMLFormElement;
    const resourceRecordUriElement = document.getElementById('resource_record_uri') as HTMLInputElement;
    const includeUnpublishedElement = document.getElementById('include_unpublished') as HTMLInputElement;

    const resourceRecordUri = resourceRecordUriElement.value;
    const includeUnpublished = includeUnpublishedElement.value === 'true';

    if (refreshResultStatusElement) {
      // eslint-disable-next-line
      refreshResultStatusElement.innerHTML = 'Downloading and reindexing... (this can take a while for large resources)';
    }

    let response;
    try {
      response = await fetch(action, {
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

      const data: RefreshResponse = await response.json();

      if (data.result && refreshResultStatusElement) {
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
      let message = err;

      if (err instanceof SyntaxError) {
        message = `Received a response status of ${response ? response.status : 'unknown'}`;
      }

      if (refreshResultStatusElement) {
        refreshResultStatusElement.innerHTML = `
          <p class="alert alert-danger mt-3">
            <strong>An unexpected error occurred</strong>:<br />${message}
          </p>
        `;
      }
    }
  });
}
