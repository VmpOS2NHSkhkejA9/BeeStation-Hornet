import { useLocalState, useBackend } from 'tgui/backend';
import { MedicalRecord, MedicalRecordData } from './types';

/** Splits a medical string on <br> into a string array */
export const getQuirkStrings = (string: string) => {
  return string?.split('<br>') || [];
};

/** We need an active reference and this a pain to rewrite */
export const getMedicalRecord = () => {
  const [selectedRecord] = useLocalState<MedicalRecord | undefined>('medicalRecord', undefined);
  if (!selectedRecord) return;
  const { data } = useBackend<MedicalRecordData>();
  const { records = [] } = data;
  const foundRecord = records.find((record) => record.record_ref === selectedRecord.record_ref);
  if (!foundRecord) return;

  return foundRecord;
};
