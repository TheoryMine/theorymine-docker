import * as request from 'request';

export function get(url: string)
  : Promise<{ status: number, body: string }> {
  return new Promise<{ status: number, body: string }>((resolve, reject) => {
    request.get(url, function (error, response, body) {
      if (!(response && response.statusCode !== undefined)) {
        reject(new Error('no response/response code'));
      } else if (error) {
        reject(error);
      } else {
        resolve({ status: response.statusCode, body: body });
      }
    });
  });
}

export function post(url :string, data: { json ?: {}, form ?: {} })
  : Promise<{ status: number, body: string }> {
  return new Promise<{ status: number, body: string }>(
    (resolve, reject) => {
      request({
          method: 'POST',
          uri: url,
          json: data.json,
          formData: data.form,
        },
        function (error, response, body) {
          if (!(response && response.statusCode !== undefined)) {
            reject(new Error('no response/response code'));
          } else if (error) {
            reject(error);
          } else {
            resolve({ status: response.statusCode, body: body });
          }
        });
    });
}