--穹瀛 双龙亦志
local this,id,ofs=GetID()
function this.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcFunFunRep(c,this.mfilter,aux.FilterBoolFunction(Card.IsFusionSetCard,0x675),1,63,true,true)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_EXTRA_ATTACK)
	e4:SetValue(1)
	c:RegisterEffect(e4)
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_NEGATE+CATEGORY_DESTROY)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_CHAINING)
	e2:SetCountLimit(1,id)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(this.discon)
	e2:SetTarget(this.distg)
	e2:SetOperation(this.disop)
	c:RegisterEffect(e2)
	local e4=Effect.CreateEffect(c)
	e4:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e4:SetProperty(EFFECT_FLAG_DELAY)
	e4:SetCode(EVENT_TO_GRAVE)
	e4:SetCountLimit(1,id+ofs)
	e4:SetTarget(this.sptg)
	e4:SetOperation(this.spop)
	c:RegisterEffect(e4)
end
function this.mfilter(c)
    return c:IsFusionSetCard(0x675) and c:IsType(TYPE_FUSION)
end
function this.discon(e,tp,eg,ep,ev,re,r,rp)
    return rp==1-tp and not e:GetHandler():IsStatus(STATUS_BATTLE_DESTROYED) and Duel.IsChainNegatable(ev)
end
function this.distg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if re:GetHandler():IsDestructable() and re:GetHandler():IsRelateToEffect(re) then
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,1,0,0)
	end
end
function this.disop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Destroy(eg,REASON_EFFECT)
	end
end
function this.spfilter(c,e,tp)
	return c:IsSetCard(0x675) and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and not c:IsHasEffect(EFFECT_NECRO_VALLEY)
end
function this.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(this.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	if chk==0 then return g:CheckWithSumEqual(Card.GetLevel,8,1,2) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,2,tp,LOCATION_DECK+LOCATION_GRAVE)
end
function this.spop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(this.spfilter,tp,LOCATION_DECK+LOCATION_GRAVE,0,nil,e,tp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sg=g:SelectWithSumEqual(tp,Card.GetLevel,8,1,2)
	if sg and sg:GetCount()>0 then
        Duel.SpecialSummon(sg,SUMMON_TYPE_SPECIAL,tp,tp,false,false,POS_FACEUP)
	end
end
