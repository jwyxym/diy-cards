--穹瀛 炎仪之道
local this,id,ofs=GetID()
function this.initial_effect(c)
	c:EnableReviveLimit()
    aux.AddFusionProcFun2(c,aux.FilterBoolFunction(Card.IsFusionSetCard,0x675),this.mfilter)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOGRAVE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(this.effcon)
	e2:SetTarget(this.rstg)
	e2:SetOperation(this.rsop)
	c:RegisterEffect(e2)
	local e4=Effect.CreateEffect(c)
    e4:SetDescription(aux.Stringid(id,0))
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
    e4:SetCode(EVENT_SPSUMMON_SUCCESS)
	e4:SetCountLimit(1,id)
	e4:SetProperty(EFFECT_FLAG_DELAY)
    e4:SetCondition(this.effcon)
	e4:SetTarget(this.ftg)
	e4:SetOperation(this.fop)
	c:RegisterEffect(e4)
	local e4=Effect.CreateEffect(c)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetCategory(CATEGORY_DESTROY)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id)
	e4:SetProperty(EFFECT_FLAG_CARD_TARGET+EFFECT_FLAG_DELAY)
	e4:SetTarget(this.destg)
	e4:SetOperation(this.desop)
	c:RegisterEffect(e4)
end
function this.mfilter(c)
    return c:IsFusionSetCard(0x675) and c:IsType(TYPE_RITUAL)
end
function this.ffilterc(c)
    return c:IsFaceup() and c:IsCode(21300304)
end
function this.ffilter0(c)
	return c:IsType(TYPE_MONSTER) and c:IsCanBeFusionMaterial() and c:IsAbleToRemove()
end
function this.ffilter1(c,e)
	return not c:IsImmuneToEffect(e)
end
function this.ffilter2(c,e,tp,m,f,chkf)
    return c:IsType(TYPE_FUSION) and c:IsSetCard(0x675) and (not f or f(c))
		and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) and c:CheckFusionMaterial(m,nil,chkf)
end
function this.effcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_FUSION)
end
function this.ftg(e,tp,eg,ep,ev,re,r,rp,chk)
    if chk==0 then
        local chkf=tp
        local mg1=Duel.GetFusionMaterial(tp)
        if Duel.IsExistingMatchingCard(this.ffilterc,tp,LOCATION_ONFIELD,0,1,nil) then
            local sg=Duel.GetMatchingGroup(this.ffilter0,tp,LOCATION_GRAVE,0,nil)
            if sg:GetCount()>0 then
                mg1:Merge(sg)
            end
        end
		local res=Duel.IsExistingMatchingCard(this.ffilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg1,nil,chkf)
		if not res then
			local ce=Duel.GetChainMaterial(tp)
			if ce~=nil then
				local fgroup=ce:GetTarget()
				local mg2=fgroup(ce,e,tp)
				local mf=ce:GetValue()
				res=Duel.IsExistingMatchingCard(this.ffilter2,tp,LOCATION_EXTRA,0,1,nil,e,tp,mg2,mf,chkf)
			end
		end
        return res
    end
    Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function this.fop(e,tp,eg,ep,ev,re,r,rp)
	local chkf=tp
	local mg1=Duel.GetFusionMaterial(tp):Filter(this.ffilter1,nil,e)
    if Duel.IsExistingMatchingCard(this.ffilterc,tp,LOCATION_ONFIELD,0,1,nil) then
        local sg=Duel.GetMatchingGroup(this.ffilter0,tp,LOCATION_GRAVE,0,nil)
        if sg:GetCount()>0 then
            mg1:Merge(sg)
        end
    end
	local sg1=Duel.GetMatchingGroup(this.ffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg1,nil,chkf)
	local mg2=nil
	local sg2=nil
	local ce=Duel.GetChainMaterial(tp)
	if ce~=nil then
		local fgroup=ce:GetTarget()
		mg2=fgroup(ce,e,tp)
		local mf=ce:GetValue()
		sg2=Duel.GetMatchingGroup(this.ffilter2,tp,LOCATION_EXTRA,0,nil,e,tp,mg2,mf,chkf)
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
            Duel.Remove(mat1:Filter(Card.IsLocation,nil,LOCATION_GRAVE),POS_FACEUP,REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.SendtoGrave(mat1:Filter(Card.IsLocation,nil,LOCATION_HAND+LOCATION_ONFIELD),REASON_EFFECT+REASON_MATERIAL+REASON_FUSION)
			Duel.BreakEffect()
			Duel.SpecialSummon(tc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)
		else
			local mat2=Duel.SelectFusionMaterial(tp,tc,mg2,nil,chkf)
			local fop=ce:GetOperation()
			fop(ce,e,tp,tc,mat2)
		end
		tc:CompleteProcedure()
	end
end
function this.rrmfilter(c)
	return c:IsSetCard(0x675) and c:IsAbleToRemove() and not c:IsHasEffect(EFFECT_NECRO_VALLEY)
end
function this.rstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then
		local mg=Duel.GetRitualMaterial(tp)
		local mg2
		if Duel.IsExistingMatchingCard(this.ffilterc,tp,LOCATION_ONFIELD,0,1,nil) then
			mg2=Duel.GetMatchingGroup(this.rrmfilter,tp,LOCATION_GRAVE,0,nil)
		end
		local res=Duel.IsExistingMatchingCard(aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,nil,aux.TRUE,e,tp,mg,mg2,Card.GetLevel,"Greater")
		return res
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function this.rsop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	::cancel::
	local mg=Duel.GetRitualMaterial(tp)
	local mg2
	if Duel.IsExistingMatchingCard(this.ffilterc,tp,LOCATION_ONFIELD,0,1,nil) then
		mg2=Duel.GetMatchingGroup(this.rrmfilter,tp,LOCATION_GRAVE,0,nil)
	end
	if c:IsControler(1-tp) or not c:IsRelateToEffect(e) or not mg:IsContains(c) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tg=Duel.SelectMatchingCard(tp,aux.RitualUltimateFilter,tp,LOCATION_HAND,0,1,1,nil,aux.TRUE,e,tp,mg,mg2,Card.GetLevel,"Greater")
	local tc=tg:GetFirst()
	if tc then
		mg=mg:Filter(Card.IsCanBeRitualMaterial,tc,tc)
		if tc.mat_filter then
			mg=mg:Filter(tc.mat_filter,tc,tp)
		else
			mg:RemoveCard(tc)
		end
		mg:Merge(mg2)
		if not mg:IsContains(c) then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		aux.GCheckAdditional=aux.RitualCheckAdditional(tc,tc:GetLevel(),"Greater")
		local mat=mg:SelectSubGroup(tp,aux.RitualCheck,true,1,tc:GetLevel(),tp,tc,tc:GetLevel(),"Greater")
		aux.GCheckAdditional=nil
		if not mat then
			aux.RCheckAdditional=nil
			goto cancel
		end
		tc:SetMaterial(mat)
		Duel.Remove(mat:Filter(Card.IsLocation,nil,LOCATION_GRAVE),POS_FACEUP,REASON_EFFECT)
		Duel.SendtoGrave(mat:Filter(Card.IsLocation,nil,LOCATION_HAND+LOCATION_ONFIELD),REASON_EFFECT)
		Duel.BreakEffect()
		Duel.SpecialSummon(tc,SUMMON_TYPE_RITUAL,tp,tp,false,true,POS_FACEUP)
		tc:CompleteProcedure()
	end
	aux.RCheckAdditional=nil
end
function this.destg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() end
	if chk==0 then return Duel.IsExistingTarget(aux.TRUE,tp,LOCATION_SZONE,LOCATION_SZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectTarget(tp,aux.TRUE,tp,LOCATION_SZONE,LOCATION_SZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,1,0,0)
end
function this.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.Destroy(tc,REASON_EFFECT)
	end
end
