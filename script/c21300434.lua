--苍炎的新生
local this,id,ofs=GetID()
function this.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(this.target)
	e1:SetOperation(this.activate)
	c:RegisterEffect(e1)
    local e2=Effect.CreateEffect(c)
    e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
    e2:SetType(EFFECT_TYPE_IGNITION)
    e2:SetRange(LOCATION_GRAVE)
    e2:SetCountLimit(1,id)
    e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
    e2:SetTarget(this.thtg)
    e2:SetOperation(this.thop)
    c:RegisterEffect(e2)
end
function this.filter(c,e,tp)
	return c:IsRace(RACE_WYRM)
end
function this.mfilter(c,e)
	return c:IsLevelAbove(0) and c:IsSetCard(0x678) and c:IsDestructable(e)
end
function this.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local mg1=Duel.GetRitualMaterial(tp)
		local mg2=Duel.GetMatchingGroup(this.mfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e)
		return Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,this.filter,e,tp,mg1,mg2,Card.GetLevel,"Greater")
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,tp,LOCATION_HAND+LOCATION_MZONE)
end
function this.activate(e,tp,eg,ep,ev,re,r,rp)
	::cancel::
	local mg1=Duel.GetRitualMaterial(tp)
	local mg2=Duel.GetMatchingGroup(this.mfilter,tp,LOCATION_HAND+LOCATION_MZONE,0,nil,e)
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
		Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		aux.GCheckAdditional=nil
		if not mat then goto cancel end
		tc:SetMaterial(mat)
		local ct1=mat:FilterCount(aux.IsInGroup,nil,mg1)
		local ct2=mat:FilterCount(aux.IsInGroup,nil,mg2)
		local dg=mat-mg1
		local mat1=mat:Clone()
		local mat2
		if ct1==0 then
			mat2=mat
			mat1:Clear()
		elseif ct2>0 and (#dg>0 or Duel.SelectYesNo(tp,aux.Stringid(id,2))) then
			local min=math.max(#dg,1)
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
			mat2=mat:SelectSubGroup(tp,this.descheck,false,min,#mat,mg2,dg)
			mat1:Sub(mat2)
		end
		if #mat1>0 then
			Duel.ReleaseRitualMaterial(mat1)
		end
		if mat2 then
			Duel.ConfirmCards(1-tp,mat2)
			Duel.Destroy(mat2,REASON_EFFECT+REASON_MATERIAL+REASON_RITUAL)
		end
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
end
function this.descheck(g,mg2,dg)
	return g:FilterCount(aux.IsInGroup,nil,dg)==#dg and mg2:FilterCount(aux.IsInGroup,nil,g)==#g
end
function this.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
    if chkc then return chkc:IsControler(tp) end
    if chk==0 then return Duel.IsExistingTarget(nil,tp,LOCATION_ONFIELD,0,1,nil) end
    Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
    local tc=Duel.SelectTarget(tp,nil,tp,LOCATION_ONFIELD,0,1,1,nil)
    Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
    Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,tp,LOCATION_GRAVE)
end
function this.thop(e,tp,eg,ep,ev,re,r,rp)
    local tc=Duel.GetFirstTarget()
    if tc:IsRelateToEffect(e) and Duel.Destroy(tc,REASON_EFFECT)>0 and e:GetHandler():IsRelateToEffect(e) then
        Duel.BreakEffect()
        Duel.SendtoHand(e:GetHandler(),tp,REASON_EFFECT)
    end
end
