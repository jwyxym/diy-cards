--驱疫姬唤醒
local s,id,o=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c,16821540)
	--发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--盖放
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SSET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
end
function s.filter(c,e,tp)
	return c:IsSetCard(0xdf88)
end
function s.mfilter(c)
	return c:GetLevel()>0 and c:IsSetCard(0xdf88) and c:IsReleasable(REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end
function s.rcheck(tp,g,c)
	return g:GetCount()==1 and not g:IsExists(Card.IsCode,1,nil,c:GetCode())
end
function s.rgcheck(g,ec)
	return g:GetCount()==1
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg1=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_DECK,0,nil)
    local mg2=Duel.GetRitualMaterial(tp):Filter(Card.IsSetCard,nil,0xdf88)
    aux.RCheckAdditional=s.rcheck
	aux.RGCheckAdditional=s.rgcheck
	local s1=Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_GRAVE,0,1,nil,s.filter,e,tp,mg1,nil,Card.GetLevel,"Equal")	
	local s2=Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,1,nil,s.filter,e,tp,mg2,nil,Card.GetLevel,"Equal")
	aux.RCheckAdditional=nil
	aux.RGCheckAdditional=nil
	local b1=s1 and (Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked())
	local b2=s2 and (Duel.GetFlagEffect(tp,id+o)==0 or not e:IsCostChecked())
	if chk==0 then return b1 or b2 end
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,2),1},
		{b2,aux.Stringid(id,3),2})
	e:SetLabel(op)
	if op==1 then
		if e:IsCostChecked() then
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND+LOCATION_GRAVE)
	elseif op==2 then
		if e:IsCostChecked() then
			Duel.RegisterFlagEffect(tp,id+o,RESET_PHASE+PHASE_END,0,1)
		end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK+LOCATION_GRAVE)
	end
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
    	::cancel1::
        aux.RCheckAdditional=s.rcheck
		aux.RGCheckAdditional=s.rgcheck
		local mg1=Duel.GetMatchingGroup(s.mfilter,tp,LOCATION_DECK,0,nil)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(aux.RitualUltimateFilter),tp,LOCATION_HAND+LOCATION_GRAVE,0,1,1,nil,s.filter,e,tp,mg1,nil,Card.GetLevel,"Equal")
		local tc=g:GetFirst()
		if tc then
			local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
			if tc.mat_filter then
				mg=mg:Filter(tc.mat_filter,tc,tp)
			else
				mg:RemoveCard(tc)
			end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
			local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
			aux.GCheckAdditional=nil
			if not mat then
            	aux.RCheckAdditional=nil
				aux.RGCheckAdditional=nil
                goto cancel1
            end
			tc:SetMaterial(mat)
			Duel.ReleaseRitualMaterial(mat)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
        aux.RCheckAdditional=nil
		aux.RGCheckAdditional=nil
    elseif op==2 then
    	::cancel2::
        aux.RCheckAdditional=s.rcheck
		aux.RGCheckAdditional=s.rgcheck
		local mg2=Duel.GetRitualMaterial(tp):Filter(Card.IsSetCard,nil,0xdf88)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(aux.RitualUltimateFilter),tp,LOCATION_DECK+LOCATION_GRAVE,0,1,1,nil,s.filter,e,tp,mg2,nil,Card.GetLevel,"Equal")
		local tc=g:GetFirst()
		if tc then
			local mg=mg2:Filter(Card.IsCanBeRitualMaterial,tc,tc)
			if tc.mat_filter then
				mg=mg:Filter(tc.mat_filter,tc,tp)
			else
				mg:RemoveCard(tc)
			end
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
			aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Equal")
			local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Equal")
			aux.GCheckAdditional=nil
			if not mat then
            	aux.RCheckAdditional=nil
				aux.RGCheckAdditional=nil
                goto cancel2
            end
			tc:SetMaterial(mat)
			Duel.ReleaseRitualMaterial(mat)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
			tc:CompleteProcedure()
		end
        aux.RCheckAdditional=nil
		aux.RGCheckAdditional=nil
	end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsCode(16821540)
end
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
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