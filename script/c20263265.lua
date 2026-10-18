-- 王家魔族·假声歌手 (ID: 20263265)
local s,id,o=GetID()
local SET_WANG_JIA=0x321

function s.initial_effect(c)
	-- ①：这张卡可以把1只光属性·恶魔族怪兽解放攻击表示上级召唤。
	-- 【修复核心】：严格对齐官方《刀皇-都牟羽沓薙》(78098950) 源码，配置 SPSUM_PARAM 与 TargetRange
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_SPSUM_PARAM)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SUMMON_PROC)
	e1:SetTargetRange(POS_FACEUP_ATTACK,0)
	e1:SetCondition(s.otcon)
	e1:SetOperation(s.otop)
	e1:SetValue(SUMMON_TYPE_ADVANCE)
	c:RegisterEffect(e1)

	-- ②：这张卡召唤·特殊召唤的场合可以发动。从卡组·墓地把1只4星以下的「王家魔族」怪兽守备表示特殊召唤。
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_GRAVE_ACTION)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_SUMMON_SUCCESS)
	e2:SetCountLimit(1,id) -- 效果②独立 HOPT
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	local e2_sp=e2:Clone()
	e2_sp:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2_sp)
end

-- ==================== ① 效果：1 祭品攻击表示上级召唤 ====================
function s.otfilter(c)
	return c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FIEND)
end

function s.otcon(e,c,minc)
	if c==nil then return true end
	local tp=c:GetControler()
	local mg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_MZONE,0,nil)
	-- 允许 1 只祭品，且场上必须有符合条件的光属性·恶魔族怪兽
	return minc<=1 and Duel.CheckTribute(c,1,1,mg,tp)
end

function s.otop(e,tp,eg,ep,ev,re,r,rp,c)
	local mg=Duel.GetMatchingGroup(s.otfilter,tp,LOCATION_MZONE,0,nil)
	-- 强制选定且仅选定 1 只符合条件的怪兽作为祭品
	local g=Duel.SelectTribute(tp,c,1,1,mg)
	c:SetMaterial(g)
	Duel.Release(g,REASON_SUMMON+REASON_MATERIAL)
end

-- ==================== ② 效果：特召 4 星以下怪兽 ====================
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_WANG_JIA) and c:IsLevelBelow(4)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end

function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local loc=LOCATION_DECK+LOCATION_GRAVE
	if chk==0 then
		return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
			and Duel.IsExistingMatchingCard(s.spfilter,tp,loc,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,loc)
end

function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local loc=LOCATION_DECK+LOCATION_GRAVE
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,loc,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end