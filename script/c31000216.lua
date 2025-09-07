--燃烧的灾厄之焰
local this,id,ofs=GetID()
function this.initial_effect(c)
	aux.AddCodeList(c,31000201)
	--select effect
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(this.target)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1)
	e2:SetCondition(this.thcon)
	e2:SetCost(this.thcost)
	e2:SetTarget(this.thtg)
	e2:SetOperation(this.thop)
	c:RegisterEffect(e2)
	this.sum_effect=e1
end
function this.filter(c,e,tp)
	return c:IsRace(RACE_BEAST+RACE_BEASTWARRIOR)
end
function this.mfilter(c)
	return c:GetLevel()>0 and (c:IsCode(31000201) or aux.IsCodeListed(c,31000201)) and c:IsType(TYPE_MONSTER) and c:IsReleasable(REASON_EFFECT|REASON_MATERIAL|REASON_RITUAL)
end
function this.rcheck(tp,g,c)
	return g:GetCount()<3
end
function this.rgcheck(g,ec)
	return g:GetCount()<3
end
function this.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local mg1=Duel.GetRitualMaterial(tp)
	local mg2=Duel.GetMatchingGroup(this.mfilter,tp,LOCATION_DECK,0,nil)
	local s1=Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_DECK,0,1,nil,this.filter,e,tp,mg1,nil,Card.GetLevel,"Equal")
	aux.RCheckAdditional=this.rcheck
	aux.RGCheckAdditional=this.rgcheck
	local s2=Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,this.filter,e,tp,mg1,mg2,Card.GetLevel,"Equal")
	aux.RCheckAdditional=nil
	aux.RGCheckAdditional=nil
	local b1=s1 and (Duel.GetFlagEffect(tp,id)==0 or not e:IsCostChecked())
	local b2=s2 and (Duel.GetFlagEffect(tp,id+ofs)==0 or not e:IsCostChecked())
	if chk==0 then return b1 or b2 end
	local op=aux.SelectFromOptions(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	if op==1 then
		if e:IsCostChecked() then
			Duel.RegisterFlagEffect(tp,id,RESET_PHASE+PHASE_END,0,1)
		end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
		e:SetOperation(this.spop1)
	elseif op==2 then
		if e:IsCostChecked() then
			Duel.RegisterFlagEffect(tp,id+ofs,RESET_PHASE+PHASE_END,0,1)
		end
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
		e:SetOperation(this.spop2)
	end
end
function this.spop1(e,tp,eg,ep,ev,re,r,rp)
	::cancel1::
	local mg1=Duel.GetRitualMaterial(tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_DECK,0,1,1,nil,this.filter,e,tp,mg1,nil,Card.GetLevel,"Greater")
	local tc=g:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		aux.GCheckAdditional=nil
		if not mat then goto cancel1 end
		tc:SetMaterial(mat)
		Duel.ReleaseRitualMaterial(mat)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function this.spop2(e,tp,eg,ep,ev,re,r,rp)
	::cancel2::
	aux.RCheckAdditional=this.rcheck
	aux.RGCheckAdditional=this.rgcheck
	local mg1=Duel.GetRitualMaterial(tp)
	local mg2=Duel.GetMatchingGroup(this.mfilter,tp,LOCATION_DECK,0,nil)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,this.filter,e,tp,mg1,mg2,Card.GetLevel,"Greater")
	local tc=g:GetFirst()
	if tc then
		local mg=mg1:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		mg:Merge(mg2)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
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
function this.setfilter(c)
	return c:IsFaceup() and aux.IsCodeListed(c,31000201)
end
function this.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(this.setfilter,tp,LOCATION_MZONE,0,1,nil)
end
function this.exfilter(c)
	return c:IsFaceup() and aux.IsCodeListed(c,31000201) and c:IsType(TYPE_RITUAL)
end
function this.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(this.setfilter,tp,LOCATION_MZONE,0,1,nil) and (Duel.CheckLPCost(tp,3000) or Duel.IsExistingMatchingCard(this.exfilter,tp,LOCATION_MZONE,0,1,nil)) end
	if Duel.IsExistingMatchingCard(this.exfilter,tp,LOCATION_MZONE,0,1,nil) then return end
	Duel.PayLPCost(tp,3000)
end
function this.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function this.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
	end
end
