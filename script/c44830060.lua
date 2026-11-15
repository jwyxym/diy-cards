--毁灭怪腕
local s,id,o=GetID()
local RENMIE=0x7ce1
local SHEN=57330010
local SHI=44830040

function s.initial_effect(c)
	aux.AddCodeList(c,SHEN)
	--①：把「毁灭怪腕」以外的手卡1张「人灭」卡或1张有「神域的物证」的卡名记述的卡给对方观看才能发动。也能把自己手卡·场上的1张其他的魔法·怪兽卡除外来发动
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.cost1)
	e1:SetTarget(s.tg1)
	e1:SetOperation(s.op1)
	c:RegisterEffect(e1)
	--②：把这个回合没有送去墓地的这张卡从墓地除外才能发动。自己墓地·除外状态的1只「人灭」怪兽特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCountLimit(1,id+1000)
	e2:SetCondition(s.con2)
	e2:SetCost(s.cost2)
	e2:SetTarget(s.tg2)
	e2:SetOperation(s.op2)
	c:RegisterEffect(e2)
	--②辅助：记录这张卡这个回合是否被送去墓地
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e0:SetCode(EVENT_TO_GRAVE)
	e0:SetOperation(s.graveop)
	c:RegisterEffect(e0)
end

--共通：这张卡的效果发动的回合，自己不是恶魔族怪兽不能特殊召唤
function s.reglimit(e,tp)
	local c=e:GetHandler()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_OATH)
	e1:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e1:SetTargetRange(1,0)
	e1:SetTarget(s.splimit)
	e1:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e1,tp)
end
function s.splimit(e,c,sump,sumtype,sumpos,targetp,se)
	if not c:IsRace(RACE_FIEND) then return true end
	if not c:IsType(TYPE_FUSION) then return false end
	--不用卡的效果的特殊召唤（接触融合等召唤规则）也禁止
	return se==nil or se:GetCode()==EFFECT_SPSUMMON_PROC
end

--①
function s.lvfilter(c)
	return c:IsSetCard(RENMIE) and c:IsType(TYPE_MONSTER) and c:IsFaceup() and c:GetLevel()>=9
end
function s.revfilter(c,e)
	return c~=e:GetHandler() and (c:IsSetCard(RENMIE) or aux.IsCodeListed(c,SHEN) or c:IsCode(SHEN))
end
function s.costfilter(c,e,tp)
	if c:IsLocation(LOCATION_GRAVE) then
		return e:GetHandler():IsSetCard(RENMIE) and c:IsAbleToRemoveAsCost() and c:IsHasEffect(SHI,tp)
	end
	return c~=e:GetHandler() and (c:IsType(TYPE_MONSTER) or c:IsType(TYPE_SPELL))
		and c:IsAbleToRemoveAsCost()
end
function s.cost1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil)
			or Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_HAND,0,1,nil,e)
			or Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,1,nil,e,tp)
	end
	e:SetLabel(0)
	local bshow=Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil)
		or Duel.IsExistingMatchingCard(s.revfilter,tp,LOCATION_HAND,0,1,nil,e)
	local bremove=Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,1,nil,e,tp)
	local useremove=false
	if bshow then
		if bremove then
			useremove=Duel.SelectOption(tp,aux.Stringid(id,8),aux.Stringid(id,9))==0
		end
	else
		useremove=true
	end
	if useremove then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
		local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND+LOCATION_MZONE+LOCATION_SZONE+LOCATION_GRAVE,0,1,1,nil,e,tp)
		local tc=g:GetFirst()
		if tc then
			local te=tc:IsHasEffect(SHI,tp)
			if te then
				te:UseCountLimit(tp)
				Duel.Remove(tc,POS_FACEUP,REASON_EFFECT+REASON_REPLACE)
			else
				Duel.Remove(tc,POS_FACEUP,REASON_COST)
			end
			e:SetLabel(1)
		end
	elseif not Duel.IsExistingMatchingCard(s.lvfilter,tp,LOCATION_MZONE,0,1,nil) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,s.revfilter,tp,LOCATION_HAND,0,1,1,nil,e)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
	end
end
function s.disfilter(c)
	return c:IsFaceup()
end
function s.tg1(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(s.disfilter,tp,0,LOCATION_ONFIELD,1,nil)
	end
	s.reglimit(e,tp)
	Duel.RegisterFlagEffect(tp,RENMIE,RESET_PHASE+PHASE_END,0,1)
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.op1(e,tp,eg,ep,ev,re,r,rp)
	s.do_common(e,tp)
	if e:GetLabel()~=1 then return end
	if not Duel.IsExistingMatchingCard(Card.IsType,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,nil,TYPE_MONSTER) then return end
	if not Duel.SelectYesNo(tp,aux.Stringid(id,10)) then return end
	Duel.BreakEffect()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local rg=Duel.SelectMatchingCard(tp,Card.IsType,tp,0,LOCATION_MZONE+LOCATION_GRAVE,1,1,nil,TYPE_MONSTER)
	if rg:GetCount()>0 then
		Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
	end
end
function s.do_common(e,tp)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.disfilter,tp,0,LOCATION_ONFIELD,1,1,nil)
	local tc=g:GetFirst()
	if tc then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_DISABLE)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	local mg=Duel.GetMatchingGroup(s.disfilter,tp,0,LOCATION_MZONE,nil)
	for tc in aux.Next(mg) do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(-1000)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		tc:RegisterEffect(e2)
	end
end

--②
function s.graveop(e,tp,eg,ep,ev,re,r,rp)
	e:GetHandler():RegisterFlagEffect(id,RESET_PHASE+PHASE_END,0,1)
end
function s.con2(e)
	return e:GetHandler():GetFlagEffect(id)==0
end
function s.cost2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToRemoveAsCost() end
	Duel.Remove(e:GetHandler(),POS_FACEUP,REASON_COST)
end
function s.spfilter(c,e,tp)
	return c:IsSetCard(RENMIE) and c:IsType(TYPE_MONSTER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.tg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,nil,e,tp)
	end
	s.reglimit(e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE+LOCATION_REMOVED)
end
function s.op2(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_GRAVE+LOCATION_REMOVED,0,1,1,nil,e,tp)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
