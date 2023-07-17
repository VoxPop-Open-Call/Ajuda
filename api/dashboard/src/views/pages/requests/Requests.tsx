import React, { useCallback, useEffect, useState } from "react";

import { CCard, CCardBody } from "@coreui/react";

import RequestTypeToggleComponent from "../../../components/RequestsComponents/AssignmentTypeToggleComponent/RequestTypeToggleComponent";
import { sortingAssigmentListByDate } from "../../../components/RequestsComponents/RequestComponentsHelperFunctions";
import RequestsTableComponent from "../../../components/RequestsComponents/RequestsTableComponent/RequestsTableComponent";
import {
  RequestProps,
  getRequestList,
} from "../../../Controllers/RequestsController/RequestsApi";
import {
  UserProps,
  getUserDetails,
} from "../../../Controllers/UserControllers/UsersApi";

import styles from "./requests.module.scss";

const Requests: React.FC = (): JSX.Element => {
  const [requestsList, setRequestsList] = useState<Array<RequestProps>>([]);
  const [pagination, setPagination] = useState({
    limit: 10,
    offset: 0,
    orderBy: "id asc",
    filter: {},
  });
  const [taskStatus, setTaskStatus] = useState({
    isAll: true,
    isComplete: false,
    isUpcoming: false,
  });
  const [newRequestsList, setNewRequestList] = useState(true);

  const getVolunteerFetch = useCallback(() => {
    if (newRequestsList) {
      const volunteerList = requestsList.map(({ assignments }) => {
        if (assignments?.length) {
          const acceptedVolunteer = sortingAssigmentListByDate(assignments);
          return getUserDetails(acceptedVolunteer[0].userId);
        }
        return null;
      });
      Promise.allSettled(volunteerList).then((volunteerResponse) => {
        const requestListWithVolunteer = requestsList.map((request, index) => {
          if (volunteerResponse[index].status === "fulfilled") {
            const successObject = volunteerResponse[
              index
            ] as PromiseFulfilledResult<{ data: UserProps }>;
            return {
              ...request,
              acceptedVolunteer: successObject?.value?.data,
            };
          } else {
            return {
              ...request,
              acceptedVolunteer: undefined,
            };
          }
        });
        setRequestsList(requestListWithVolunteer);
      });
      setNewRequestList(false);
    }
  }, [newRequestsList, requestsList]);

  useEffect(() => {
    if (requestsList.length) {
      getVolunteerFetch();
    }
  }, [getVolunteerFetch, requestsList.length]);

  const requestListFetch = useCallback(() => {
    getRequestList(pagination, taskStatus)
      .then(({ data }) => {
        const _data = data.map((obj) => ({
          ...obj,
          _props: { className: styles.tableRowStyle },
        }));
        setRequestsList(_data);
        setNewRequestList(true);
      })
      .catch(({ response }) => {
        window.alert(response.data.error.message);
      });
  }, [pagination, taskStatus]);

  useEffect(() => {
    requestListFetch();
  }, [requestListFetch]);

  return (
    <CCard className={styles.containingCard}>
      <CCardBody className={styles.containingCardBody}>
        <div className={styles.headerContainerDiv}>
          <div className={styles.pageTitle}>Requests</div>
          <RequestTypeToggleComponent
            taskStatus={taskStatus}
            setTaskStatus={setTaskStatus}
          />
        </div>
        <div className={styles.tableDiv}>
          <RequestsTableComponent
            tableData={requestsList}
            pagination={pagination}
            setPagination={setPagination}
          />
        </div>
      </CCardBody>
    </CCard>
  );
};

export default Requests;
