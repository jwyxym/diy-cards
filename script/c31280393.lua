--姦淫的羽翼
local s,id,o=GetID()
function s.initial_effect(c)
	--发动
	local e1=Effect.CreateEffect(c)
    e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.eftg)
	e1:SetOperation(s.efop)
	c:RegisterEffect(e1)
end
function s.filter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function s.filter2(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and c:IsSetCard(0x5ca1) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x5ca1) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and (c:IsFaceup() or c:IsLocation(LOCATION_GRAVE))
    	and c:IsCanBeFusionMaterial()
end
function s.fusfilter(c,e,tp,mg)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and c:IsLevelBelow(6)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(mg)
end
function s.fselect(g,e,tp)
	return Duel.IsExistingMatchingCard(s.fusfilter,tp,LOCATION_EXTRA,0,1,nil,e,tp,g)
end
function s.confilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsRace(RACE_FIEND) and c:IsLevelBelow(6) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0
end
function s.eftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp)
	local res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
	if not res then
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			local mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			res=Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
		end
	end
    local cg=Duel.GetMatchingGroup(s.confilter,tp,LOCATION_EXTRA,0,nil,tp)
    local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
    local b1=res and (Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked())
    local b2=Duel.IsPlayerCanSpecialSummonCount(tp,2) and not Duel.IsPlayerAffectedByEffect(tp,59822133)
    	and Duel.GetLocationCount(tp,LOCATION_MZONE)>=2 and Duel.GetLP(tp)>=400 and g:CheckSubGroup(s.fselect,2,2,e,tp)
        and cg:GetCount()>0 and (Duel.GetFlagEffect(tp,id+o)==0 or not e:IsCostChecked())
	if chk==0 then return (b1 or b2) end
    local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1),1},
		{b2,aux.Stringid(id,2),2})
    e:SetLabel(op)
    local loc=0
	if op==1 then
		if e:IsCostChecked() then
        	loc=LOCATION_EXTRA
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_ATKCHANGE+CATEGORY_DEFCHANGE)
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
	elseif op==2 then
		if e:IsCostChecked() then
        	loc=LOCATION_GRAVE+LOCATION_EXTRA
			e:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
  	end      
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
    if op==1 then
		local chkf=tp
		local mg1=Duel.GetFusionMaterial(tp):Filter(s.filter1,nil,e)
		local sg1=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
		local mg2=nil
		local sg2=nil
		local ce=Duel.GetChainMaterial(tp)
		if ce~=nil then
			local fgroup=ce:GetTarget()
			mg2=fgroup(ce,e,tp)
			local mf=ce:GetValue()
			sg2=Duel.GetMatchingGroup(s.filter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
		end
		if sg1:GetCount()>0 or (sg2~=nil and sg2:GetCount()>0) then
			local sg=sg1:Clone()
			if sg2 then sg:Merge(sg2) end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			local tg=sg:Select(tp,1,1,nil)
			local tc=tg:GetFirst()
			if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or not Duel.SelectYesNo(tp,ce:GetDescription())) then
				local mat1=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
				tc:SetMaterial(mat1)
				Duel.SendtoGrave(mat1,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.BreakEffect()
				Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
			else
				local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
				local fop=ce:GetOperation()
				fop(ce,e,tp,tc,mat2)
			end
			tc:CompleteProcedure()
            local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(800)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
            local e2=e1:Clone()
			e2:SetCode(EFFECT_UPDATE_DEFENSE)
			tc:RegisterEffect(e2)
        end   
    elseif op==2 then
    	if Duel.GetLP(tp)>=400 and Duel.PayLPCost(tp,400)~=0 and Duel.IsPlayerCanSpecialSummonCount(tp,2) 
        	and not Duel.IsPlayerAffectedByEffect(tp,59822133) and Duel.GetLocationCount(tp,LOCATION_MZONE)>1 then
        	local cg=Duel.GetMatchingGroup(s.confilter,tp,LOCATION_EXTRA,0,nil,tp)
			if cg:GetCount()>0 then
            	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil,e,tp)
				Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sg=g:SelectSubGroup(tp,s.fselect,false,2,2,e,tp)
				if not sg then return end
                for tc in aux.Next(sg) do
                	Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP)
                	local e1=Effect.CreateEffect(e:GetHandler())
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_DISABLE)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					tc:RegisterEffect(e1)
					local e2=e1:Clone()
					e2:SetCode(EFFECT_DISABLE_EFFECT)
					e2:SetValue(RESET_TURN_SET)
					tc:RegisterEffect(e2)
                end
                Duel.SpecialSummonComplete()
                local og=Duel.GetOperatedGroup()
				Duel.AdjustAll()
                if og:FilterCount(Card.IsLocation,nil,LOCATION_MZONE)<2 then return end
                Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
				local sc=Duel.SelectMatchingCard(tp,s.fusfilter,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,og):GetFirst()
                if not sc then return end
                sc:SetMaterial(og)
                Duel.SendtoGrave(og,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
				Duel.BreakEffect()
				Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
				local fid=sc:GetFieldID()
				sc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
				sc:CompleteProcedure()
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
				e1:SetCode(EVENT_PHASE+PHASE_END)
				e1:SetCountLimit(1)
				e1:SetLabelObject(sc)
				e1:SetLabel(Duel.GetTurnCount()+1)
				e1:SetCondition(s.txcon(fid))
				e1:SetOperation(s.txop)
				e1:SetReset(RESET_PHASE+PHASE_END,2)
				Duel.RegisterEffect(e1,tp)
            end
        end	     
	end
end
function s.txcon(fid)
	return function(e,tp,eg,ep,ev,re,r,rp)
			local tc=e:GetLabelObject()
			if tc:GetFlagEffect(id)~=0 and tc:GetFlagEffectLabel(id)==fid then
				return Duel.GetTurnCount()==e:GetLabel()
			else
				e:Reset()
				return false
			end
	end
end
function s.txop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local tc=e:GetLabelObject()
	if tc and tc:IsOnField() then
		Duel.SendtoDeck(tc,nil,2,REASON_EFFECT)
	end
end