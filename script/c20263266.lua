-- 王家魔族·极端金属歌手 (ID: 20263266)
local s,id,o=GetID()
function s.initial_effect(c)
	-- ①：这张卡把5星以上怪兽解放来进行上级召唤的场合，以对方场上1只怪兽为对象才能发动。
	-- 这个回合，自己把光属性·恶魔族怪兽上级召唤的场合，可以作为自己场上1只怪兽的代替而把那只对方怪兽解放。这个回合，自己不能从额外卡组把怪兽特殊召唤。
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)

	-- 注册素材检查：记录解放的素材是否包含5星以上怪兽
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)

	-- ②：只要上级召唤的这张卡在场上表侧表示存在，自己场上的「王家魔族」怪兽不会成为对方效果的对象。
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.tgcon)
	e2:SetTarget(s.tgtg)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
end

-- ==================== 效果 ① 相关处理 ====================
function s.valcheck(e,c)
	local g=c:GetMaterial()
	if g:IsExists(Card.IsLevelAbove,1,nil,5) then
		e:SetLabel(1)
	else
		e:SetLabel(0)
	end
end

function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local mg=c:GetMaterial()
	-- 校验为上级召唤，且解放的素材中包含5星以上怪兽
	return c:IsSummonType(SUMMON_TYPE_ADVANCE)
		and (e:GetLabel()==1 or (mg and mg:IsExists(Card.IsLevelAbove,1,nil,5)))
end

function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(1-tp) and chkc:IsLocation(LOCATION_MZONE) end
	if chk==0 then return Duel.IsExistingTarget(nil,tp,0,LOCATION_MZONE,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	Duel.SelectTarget(tp,nil,tp,0,LOCATION_MZONE,1,1,nil)
end

function s.exval(e,c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FIEND)
end

function s.splimit(e,c)
	return c:IsLocation(LOCATION_EXTRA)
end

function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	local c=e:GetHandler()
	-- 这个回合，可以作为自己场上1只怪兽的代替而把那只对方怪兽解放
	if tc and tc:IsRelateToEffect(e) then
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(aux.Stringid(id,1))
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
		e1:SetCode(EFFECT_EXTRA_RELEASE_SUM)
		e1:SetValue(s.exval)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
	end
	-- 这个回合，自己不能从额外卡组把怪兽特殊召唤
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,2))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	e2:SetReset(RESET_PHASE+PHASE_END)
	Duel.RegisterEffect(e2,tp)
end

-- ==================== 效果 ② 相关处理 ====================
function s.tgcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_ADVANCE)
end

function s.tgtg(e,c)
	return c:IsSetCard(0x321)
end