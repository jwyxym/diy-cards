--杀血鬼-吸血鬼·里昂
local s,id=GetID()
function s.initial_effect(c)
	aux.AddCodeList(c, 80485722)
	
	--① 把自己场上1只「吸血鬼」怪兽解放，这张卡从墓地特召
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCountLimit(1,id)
	e1:SetCost(s.spcost)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)

	--② 召唤·特殊召唤的场合，从墓地拿1张「吸血鬼」卡
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCountLimit(1,id+100)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
	local e2b=e2:Clone()
	e2b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2b)

	--③-1 自己场上「吸血鬼」怪兽不受对方暗属性怪兽效果影响
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(LOCATION_MZONE,0)
	e3:SetTarget(s.immtg)
	e3:SetValue(s.efilter)
	c:RegisterEffect(e3)

	--③-2 这张卡在手卡·场上也当作「吸血鬼杀手」使用
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE+EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EFFECT_ADD_CODE)
	e4:SetRange(LOCATION_HAND+LOCATION_MZONE)
	e4:SetValue(80485722)
	c:RegisterEffect(e4)
end

-- ① 可解放过滤（★ 照抄《刀魂》的完美判定）
function s.relfilter(c)
	if c:IsSetCard(0x8e) and c:IsType(TYPE_MONSTER) and c:IsReleasable() then
		-- 如果自己场上怪兽区（含EX区）全满，只能解放主怪兽区的怪兽
		if Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE,PLAYER_NONE,LOCATION_REASON_TOFIELD,0x7f)<=0 then
			return c:GetSequence()<5
		end
		return true
	end
	return false
end

-- ① cost：解放
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.relfilter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local g=Duel.SelectMatchingCard(tp,s.relfilter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.Release(g,REASON_COST)
end

-- ① target
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,0,0)
end

-- ① 处理
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end

-- ② 过滤：墓地「吸血鬼」卡
function s.thfilter(c)
	return c:IsSetCard(0x8e) and c:IsAbleToHand()
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end

-- ③-1 过滤：自己场上「吸血鬼」怪兽
function s.immtg(e,c)
	return c:IsSetCard(0x8e) and c:IsType(TYPE_MONSTER)
end

-- ③-1 免疫判定：对方暗属性怪兽效果
function s.efilter(e,te)
	local tc=te:GetOwner()
	return tc and tc:IsAttribute(ATTRIBUTE_DARK) and tc:GetControler()~=e:GetHandlerPlayer()
end

return s
