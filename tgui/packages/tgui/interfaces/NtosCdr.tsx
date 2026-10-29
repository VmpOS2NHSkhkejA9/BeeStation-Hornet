import { useState } from 'react';
import { Box, Button, Flex, ProgressBar, Section } from 'tgui-core/components';

import { useBackend } from '../backend';
import { NtosWindow } from '../layouts';
import { CdrContent, CdrData } from './AtmosCdr/CdrContent';
import { CdrHelpMenu } from './AtmosCdr/CdrHelpMenu';

export const NtosCdr = (props) => {
  type CdrDataList = Record<string, CdrData>;

  type Data = {
    cdr_data: CdrDataList;
    selected_cdr_uid: number;
  };

  const { act, data } = useBackend<Data>();
  const { cdr_data, selected_cdr_uid } = data;
  const [helpMenuOpen, setHelpMenuOpen] = useState(false);
  const activeCdr = Object.values(cdr_data).find(
    (cdr) => cdr.uid === selected_cdr_uid,
  );
  // height={800} width={460}
  return (
    <NtosWindow height={activeCdr ? 750 : 400} width={activeCdr ? 460 : 700}>
      <NtosWindow.Content scrollable>
        {activeCdr ? (
          <Box>
            <Section
              fitted
              title={`${activeCdr.uid}. at ${activeCdr.area}`}
              buttons={
              <Box>
                <Button
                  icon="arrow-left"
                  onClick={() => act('select_cdr', { select_cdr: null })}>
                  Back
                </Button>
                <Button
                  icon="question"
                  selected={helpMenuOpen}
                  onClick={() => setHelpMenuOpen(!helpMenuOpen)}>
                  Help
                </Button>
              </Box>} />
            {helpMenuOpen ? <CdrHelpMenu /> : <CdrContent {...activeCdr} />}
          </Box>
        ) : (
          <Section title="Detected Condensate Decay Reactors" buttons={
            <Button
              icon="sync"
              content="Refresh"
              onClick={() => act('refresh')}
            />}>
            <Flex>
              {Object.values(cdr_data).map((cdr) => {
                return (
                  <Flex.Item key={cdr.uid}>
                    <Flex>
                      <Flex.Item fill m={0.5}>
                      {`${cdr.uid}. ${cdr.area}`}
                      </Flex.Item>
                      <Flex.Item>
                        <ProgressBar
                          value={((cdr.core_instability - cdr.core_stability) / cdr.core_instability) * 100} />
                      </Flex.Item>
                      <Flex.Item fill>
                        <Button
                          content={"Details"}
                          onClick={() =>
                            act('select_cdr', {
                              select_cdr: cdr.uid,
                            })
                          }
                        />
                      </Flex.Item>
                    </Flex>
                  </Flex.Item>
                );
              })}
            </Flex>
          </Section>
        )}
      </NtosWindow.Content>
    </NtosWindow>
  );
};
