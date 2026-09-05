--丹紫之献身-创造之九
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,31280120)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON+CATEGORY_TODECK+CATEGORY_GRAVE_ACTION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
    e1:SetCountLimit(1,id+EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.fsptg)
	e1:SetOperation(s.fspop)
	c:RegisterEffect(e1)    
	--盖放    
    local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_TO_GRAVE)
	e2:SetProperty(EFFECT_FLAG_DELAY)
    e2:SetCountLimit(1,id)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)    
end
function s.filter(c,e,tp,m,f,chkf)
	return c:IsType(TYPE_FUSION) and (not f or f(c)) and c:IsRace(RACE_MACHINE)
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function s.filter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck()
    	and c:GetOriginalRace()==RACE_ZOMBIE
end
function s.filter1(c,e)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToDeck() and not c:IsImmuneToEffect(e)
    	and c:GetOriginalRace()==RACE_ZOMBIE
end
function s.cfilter(c)
	return aux.IsCodeListed(c,31280120)
end    
function s.fcheck(tp,g,fc)
	return g:IsExists(s.cfilter,1,nil)
end
function s.fsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local chkf=tp
		local mg1=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
		aux.FCheckAdditional=s.fcheck
		local res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
		aux.FCheckAdditional=nil
		return res
	end    
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.eqfilter(c,tp)
	return c:IsType(TYPE_MONSTER) and c:IsAbleToChangeControler() and not c:IsForbidden() and c:CheckUniqueOnField(tp)
end
function s.fspop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetMatchingGroup(s.filter0,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,nil)
	aux.FCheckAdditional=s.fcheck
	local sg1=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2,sg2=nil,nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(s.filter,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
	end
	if #sg1>0 or (sg2~=nil and #sg2>0) then
		local sg=sg1:Clone()
		if sg2 then sg:Merge(sg2) end
        local mag=Group.CreateGroup()
		::cancel::
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local tc=sg:Select(tp,1,1,nil):GetFirst()
		if sg1:IsContains(tc) and (sg2==nil or not sg2:IsContains(tc) or ce and not Duel.SelectYesNo(tp,ce:GetDescription())) then
			local mat=Duel.SelectFusionMaterial(tp,tc,mg1,nil,chkf)
			if #mat==0 then goto cancel end
			tc:SetMaterial(mat)
            if mat:IsExists(Card.IsFacedown,1,nil) then
				local cg1=mat:Filter(Card.IsFacedown,nil)
				Duel.ConfirmCards(1-tp,cg1)
			end
			if mat:IsExists(Card.IsLocation,1,nil,LOCATION_GRAVE+LOCATION_REMOVED) then
				local cg2=mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE+LOCATION_REMOVED)
				Duel.HintSelection(cg2)
			end			
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
            mag=mat
		elseif ce then
			local mat=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			if #mat==0 then goto cancel end
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat)
            mag=mat
		end
		tc:CompleteProcedure()
        Duel.BreakEffect()
        local c=e:GetHandler()
        local feg=mag:Filter(aux.NecroValleyFilter(s.eqfilter),nil,tp)
        local ft=Duel.GetLocationCount(tp,LOCATION_SZONE)
        if feg:GetCount()>0 and ft>0 and tc:IsFaceup() and tc:IsLocation(LOCATION_MZONE)
        	and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then 
        	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EQUIP)
            local fg=feg:Select(tp,1,ft,nil)
            if fg:GetCount()>0 then
            	Duel.HintSelection(fg)
    			for ec in aux.Next(fg) do
					if not Duel.Equip(tp,ec,tc) then return end
					local e1=Effect.CreateEffect(c)
					e1:SetType(EFFECT_TYPE_SINGLE)
					e1:SetCode(EFFECT_EQUIP_LIMIT)
					e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
					e1:SetLabelObject(tc)
					e1:SetReset(RESET_EVENT+RESETS_STANDARD)
					e1:SetValue(s.eqlimit)
					ec:RegisterEffect(e1)
       			 	local e2=Effect.CreateEffect(c)
					e2:SetType(EFFECT_TYPE_EQUIP)
					e2:SetCode(EFFECT_UPDATE_ATTACK)
					e2:SetValue(400)
					e2:SetReset(RESET_EVENT+RESETS_STANDARD)
					ec:RegisterEffect(e2)
				end
            end
            mag:Sub(fg)
        end
        local tdg=mag:Filter(aux.NecroValleyFilter(Card.IsAbleToDeck),nil)
        if tdg:GetCount()>0 then
        	Duel.SendtoDeck(tdg,nil,2,REASON_EFFECT)
        end    
	end
	aux.FCheckAdditional=nil
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return not e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsSSetable() end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SSet(tp,c)
	end
end